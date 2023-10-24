//
//  MyCPUUsage.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//
// From: https://github.com/mattgallagher/CwlUtils/blob/master/Sources/CwlUtils/CwlSysctl.swift

import Combine
import Foundation

class MyCPUUsage {
    let coreUsagesPublisher = PassthroughSubject<[CoreUsage], Never>()

    private var cpuInfo: processor_info_array_t?
    private var prevCpuInfo: processor_info_array_t?
    private var numCpuInfo: mach_msg_type_number_t = 0
    private var numPrevCpuInfo: mach_msg_type_number_t = 0
    private var numCPUs: uint = 0
    private var updateTimer: Timer?
    private let CPUUsageLock: NSLock = NSLock()

    init() {
        let mibKeys = [CTL_HW, HW_NCPU]

        mibKeys.withUnsafeBufferPointer { mib in
            var sizeOfNumCPUs: size_t = MemoryLayout<uint>.size
            let status = sysctl(processor_info_array_t(mutating: mib.baseAddress), 2, &numCPUs, &sizeOfNumCPUs, nil, 0)
            if status != 0 {
                numCPUs = 1
            }
        }
    }

    func startMonitoring() {
        self.updateTimer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(updateInfo),
            userInfo: nil,
            repeats: true
        )
    }

    func stopMonitoring() {
        self.updateTimer?.invalidate()
    }
}

private extension MyCPUUsage {
    @objc func updateInfo(_ timer: Timer) {
        var numCPUsU: natural_t = 0
        let err: kern_return_t = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &numCPUsU,
            &cpuInfo,
            &numCpuInfo
        )

        guard err == KERN_SUCCESS else {
            print("Error getting CPU Usage")
            return
        }

        CPUUsageLock.lock()

        var coreUsages = [CoreUsage]()
        coreUsages.reserveCapacity(Int(numCPUs))

        for ctr in 0 ..< Int32(numCPUs) {
            guard let cpuInfo else {
                print("Error getting CPU Usage")
                return
            }

            var inUse: Int32
            var total: Int32

            if let prevCpuInfo = prevCpuInfo {
                inUse = cpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_USER)]
                    - prevCpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_USER)]
                    + cpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_SYSTEM)]
                    - prevCpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_SYSTEM)]
                    + cpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_NICE)]
                    - prevCpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_NICE)]
                total = inUse + (cpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_IDLE)]
                                    - prevCpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_IDLE)])
            } else {
                inUse = cpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_USER)]
                    + cpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_SYSTEM)]
                    + cpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_NICE)]
                total = inUse + cpuInfo[Int(CPU_STATE_MAX * ctr + CPU_STATE_IDLE)]
            }

            coreUsages.append(.init(id: Int(ctr + 1), usage: Float(inUse) / Float(total)))
        }

        CPUUsageLock.unlock()

        self.coreUsagesPublisher.send(coreUsages)

        if let prevCpuInfo = prevCpuInfo {
            // vm_deallocate Swift usage credit rsfinn: https://stackoverflow.com/a/48630296/1033581
            let prevCpuInfoSize: size_t = MemoryLayout<integer_t>.stride * Int(numPrevCpuInfo)
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: prevCpuInfo), vm_size_t(prevCpuInfoSize))
        }

        prevCpuInfo = cpuInfo
        numPrevCpuInfo = numCpuInfo

        cpuInfo = nil
        numCpuInfo = 0
    }
}
