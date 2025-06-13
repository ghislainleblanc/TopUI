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

final class MySystemStats {
    @Published private(set) var coreUsages = [CoreUsage]()
    @Published private(set) var memoryUsage = MemoryUsage(
        free: 0,
        active: 0,
        inactive: 0,
        wired: 0,
        compressed: 0,
        total: 0
    )
    @Published private(set) var gpuUsage = 0
    @Published private(set) var networkUsage = NetworkUsage(rxBytesPerSecond: 0, txBytesPerSecond: 0)

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
        var stats = vm_statistics64()
        var count = UInt32(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)

        let hostVMInfo64: host_flavor_t = 4
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), hostVMInfo64, $0, &count)
            }
        }

        if result != KERN_SUCCESS {
            return
        }

        let pageSize = UInt64(vm_kernel_page_size)

        let free = UInt64(stats.free_count) * pageSize
        let active = UInt64(stats.active_count) * pageSize
        let inactive = UInt64(stats.inactive_count) * pageSize
        let wired = UInt64(stats.wire_count) * pageSize
        let compressed = UInt64(stats.compressor_page_count) * pageSize

        let total = free + active + inactive + wired + compressed

        memoryUsage = MemoryUsage(
            free: free,
            active: active,
            inactive: inactive,
            wired: wired,
            compressed: compressed,
            total: total
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
        var rxBytes = UInt64.zero
        var txBytes = UInt64.zero

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

        networkUsage = NetworkUsage(rxBytesPerSecond: rxBytes, txBytesPerSecond: txBytes)
    }
}
