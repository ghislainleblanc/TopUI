//
//  MySystemStats.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//
// From: https://github.com/mattgallagher/CwlUtils/blob/master/Sources/CwlUtils/CwlSysctl.swift

import Combine
import Foundation

class MySystemStats {
    private let coreUsagesSubject = CurrentValueSubject<[CoreUsage], Never>([])
    var coreUsagesPublisher: AnyPublisher<[CoreUsage], Never> {
        coreUsagesSubject.eraseToAnyPublisher()
    }

    private let memoryUsageSubject = CurrentValueSubject<MemoryUsage, Never>(
        .init(
            free: 0,
            active: 0,
            inactive: 0,
            wired: 0,
            compressed: 0
        )
    )
    var memoryUsagePublisher: AnyPublisher<MemoryUsage, Never> {
        memoryUsageSubject.eraseToAnyPublisher()
    }

    private var cpuInfo: processor_info_array_t?
    private var prevCpuInfo: processor_info_array_t?
    private var numCpuInfo: mach_msg_type_number_t = 0
    private var numPrevCpuInfo: mach_msg_type_number_t = 0
    private var numCPUs = 0
    private var updateTimer: Timer?
    private let CPUUsageLock = NSLock()

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
        updateTimer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(updateInfo),
            userInfo: nil,
            repeats: true
        )
    }

    func stopMonitoring() {
        updateTimer?.invalidate()
    }
}

private extension MySystemStats {
    @objc
    func updateInfo() {
        getMemoryUsage()
        getCPUUsage()
    }

    func getMemoryUsage() {
        let systemMemoryUsage = System.memoryUsage()
        let memoryUsage = MemoryUsage(
            free: systemMemoryUsage.free,
            active: systemMemoryUsage.active,
            inactive: systemMemoryUsage.inactive,
            wired: systemMemoryUsage.wired,
            compressed: systemMemoryUsage.compressed
        )

        memoryUsageSubject.send(memoryUsage)
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

        var coreUsages = [CoreUsage]()
        coreUsages.reserveCapacity(numCPUs)

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

            coreUsages.append(.init(id: ctr + 1, usage: Float(inUse) / Float(total)))
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

        coreUsagesSubject.send(coreUsages)
    }
}
