//
//  MySystemStats.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//
//  From: https://github.com/mattgallagher/CwlUtils/blob/master/Sources/CwlUtils/CwlSysctl.swift

@preconcurrency import Darwin
import Combine
import Foundation

class MySystemStats {
    @Published private(set) var coreUsages = [CoreUsage]()
    @Published private(set) var memoryUsage: MemoryUsage = .init(
        free: 0,
        active: 0,
        inactive: 0,
        wired: 0,
        compressed: 0,
        physical: 0
    )
    @Published private(set) var gpuUsage = 0
    @Published private(set) var networkUsage: NetworkUsage = .init(rxBytesPerSecond: 0, txBytesPerSecond: 0)

    private var cpuInfo: processor_info_array_t?
    private var prevCpuInfo: processor_info_array_t?
    private var numCpuInfo: mach_msg_type_number_t = 0
    private var numPrevCpuInfo: mach_msg_type_number_t = 0
    private var numCPUs = 0
    private let CPUUsageLock = NSLock()

    private var cancellables = [AnyCancellable]()

    init() {
        [CTL_HW, HW_NCPU].withUnsafeBufferPointer { mib in
            var sizeOfNumCPUs = MemoryLayout<uint>.size
            let status = sysctl(
                processor_info_array_t(mutating: mib.baseAddress),
                2,
                &numCPUs,
                &sizeOfNumCPUs,
                nil,
                0
            )

            if status != 0 {
                numCPUs = 1
            }
        }
    }

    func startMonitoring() {
        Timer
            .publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateInfo()
            }
            .store(in: &cancellables)
    }
}

private extension MySystemStats {
    func updateInfo() {
        getCPUUsage()
        getMemoryUsage()
        getGPUUsage()
        getNetworkUsage()
    }

    func getMemoryUsage() {
        let systemMemoryUsage = System.memoryUsage()

        memoryUsage = MemoryUsage(
            free: systemMemoryUsage.free,
            active: systemMemoryUsage.active,
            inactive: systemMemoryUsage.inactive,
            wired: systemMemoryUsage.wired,
            compressed: systemMemoryUsage.compressed,
            physical: System.physicalMemory()
        )
    }

    func getCPUUsage() {
        var numCPUsU: natural_t = 0
        let err = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &numCPUsU,
            &cpuInfo,
            &numCpuInfo
        )

        guard err == KERN_SUCCESS else { return }

        CPUUsageLock.lock()

        var newCoreUsages = [CoreUsage]()
        newCoreUsages.reserveCapacity(numCPUs)

        for ctr in 0..<Int32(numCPUs) {
            guard let cpuInfo else { return }

            var inUse: Int32
            var total: Int32

            if let prevCpuInfo = prevCpuInfo {
                inUse = cpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_USER)]
                    - prevCpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_USER)]
                    + cpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_SYSTEM)]
                    - prevCpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_SYSTEM)]
                    + cpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_NICE)]
                    - prevCpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_NICE)]
                total = inUse
                    + (cpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_IDLE)]
                        - prevCpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_IDLE)])
            } else {
                inUse = cpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_USER)]
                    + cpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_SYSTEM)]
                    + cpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_NICE)]
                total = inUse + cpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_IDLE)]
            }

            newCoreUsages.append(.init(id: ctr + 1, usage: Float(inUse) / Float(total)))
        }

        CPUUsageLock.unlock()

        if let prevCpuInfo = prevCpuInfo {
            // vm_deallocate Swift usage credit rsfinn: https://stackoverflow.com/a/48630296/1033581
            let prevCpuInfoSize: size_t = MemoryLayout<integer_t>.stride * Int(numPrevCpuInfo)
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: prevCpuInfo), vm_size_t(prevCpuInfoSize))
        }

        prevCpuInfo = cpuInfo
        numPrevCpuInfo = numCpuInfo

        cpuInfo = nil
        numCpuInfo = 0

        coreUsages = newCoreUsages
    }

    func getGPUUsage() {
        var accelerators = [[String: AnyObject]]()
        var iterator = io_iterator_t()

        if IOServiceGetMatchingServices(
            kIOMainPortDefault,
            IOServiceMatching(kIOAcceleratorClassName),
            &iterator
        ) == kIOReturnSuccess {
            repeat {
                let entry = IOIteratorNext(iterator)
                defer {
                    IOObjectRelease(entry)
                }
                guard entry != 0 else {
                    break
                }
                var serviceDict: Unmanaged<CFMutableDictionary>?

                guard IORegistryEntryCreateCFProperties(
                    entry, &serviceDict,
                    kCFAllocatorDefault,
                    0
                ) == kIOReturnSuccess else {
                    break
                }
                if let serviceDict {
                    accelerators.append(
                        Dictionary(
                            uniqueKeysWithValues: (serviceDict.takeRetainedValue() as NSDictionary as Dictionary).map {
                                ($0 as! String, $1) // swiftlint:disable:this force_cast
                            }
                        )
                    )
                }
            } while true

            IOObjectRelease(iterator)

            if let statistics = accelerators.first?["PerformanceStatistics"] {
                let utilizationCandidates = [
                    (statistics["Device Utilization %"] as? NSNumber)?.intValue,
                    (statistics["hardwareWaitTime"] as? NSNumber).map {
                        max(min($0.intValue / 1000 / 1000 / 10, 100), 0)
                    }
                ]

                gpuUsage = utilizationCandidates.reduce(nil, { $0 ?? $1 }) ?? 0
            }
        }
    }

    func getNetworkUsage() {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        var rxBytes: UInt64 = 0
        var txBytes: UInt64 = 0

        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                if let ifa = ptr?.pointee, ifa.ifa_addr?.pointee.sa_family == UInt8(AF_LINK) {
                    let data = unsafeBitCast(ifa.ifa_data, to: UnsafePointer<if_data>?.self)?.pointee
                    rxBytes += UInt64(data?.ifi_ibytes ?? 0)
                    txBytes += UInt64(data?.ifi_obytes ?? 0)
                }
                ptr = ptr?.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }

        networkUsage = .init(rxBytesPerSecond: rxBytes, txBytesPerSecond: txBytes)
    }
}
