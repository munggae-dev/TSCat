// Copyright 2026 TSCat contributors
// SPDX-License-Identifier: Apache-2.0
// Added for TSCat: battery charging information and tests.
import DataSource
import SwiftUI

struct ChargingInfoView: View {
    let info: ChargingInfo

    private var status: String {
        if info.isFull { return "충전 완료" }
        guard info.isCharging else { return "충전 대기 중" }
        guard let minutes = info.minutesToFull else { return "완충까지: 계산 중" }
        let hours = minutes / 60
        let remainder = minutes % 60
        let duration = hours == 0 ? "\(remainder)분" :
            (remainder == 0 ? "\(hours)시간" : "\(hours)시간 \(remainder)분")
        return "완충까지 약 \(duration)"
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "battery.100percent.bolt")
            VStack(alignment: .leading, spacing: 4) {
                Text(status)
                if info.isCharging, let watts = info.watts {
                    Text("배터리 충전 전력: \(watts, specifier: "%.1f") W")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .materialCellStyle()
    }
}
