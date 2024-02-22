//
//  GroupCalendarView.swift
//  Namo_SwiftUI
//
//  Created by 정현우 on 2/19/24.
//

import SwiftUI
import Factory
import SwiftUICalendar

struct GroupCalendarView: View {
	@Injected(\.scheduleInteractor) var scheduleInteractor
	@Injected(\.categoryInteractor) var categoryInteractor
	@Injected(\.moimInteractor) var moimInteractor
	@StateObject var calendarController = CalendarController()
	@EnvironmentObject var appState: AppState
	@Environment(\.dismiss) var dismiss
	
	let moim: Moim
	
	// datePicker
	@State var showDatePicker: Bool = false
	@State var datePickerCurrentDate: Date = Date()
	@State var pickerCurrentYear: Int = Date().toYMD().year
	@State var pickerCurrentMonth: Int = Date().toYMD().month
	
	// groupInfo
	@State var showGroupInfo: Bool = false
	@State var groupName: String = ""
	@State var newGroupName: String = ""
	let gridColumn: [GridItem] = Array(repeating: GridItem(.flexible()), count: 2)
	
	// calendar
	@State var focusDate: YearMonthDay? = nil
	@State var calendarSchedule: [YearMonthDay: [CalendarSchedule]] = [:]
	
	let weekdays: [String] = ["일", "월", "화", "수", "목", "금", "토"]
	
    var body: some View {
		ZStack {
			VStack(spacing: 0) {
				header
					.padding(.bottom, 22)
				
				weekday
					.padding(.bottom, 11)
				
				CalendarView(calendarController) { date in
					CalendarItem(date: date, focusDate: $focusDate, calendarSchedule: $calendarSchedule)
				}
				.frame(width: screenWidth-20)
				.padding(.leading, 14)
				.padding(.trailing, 6)
				.padding(.bottom, 20)
				
			}
			
			if showDatePicker {
				datePicker
			}
			
			if showGroupInfo {
				groupInfo
			}
		}
		.toolbar(.hidden, for: .navigationBar)
		.onAppear {
			groupName = moim.groupName ?? ""
		}
    }
	
	private var header: some View {
		HStack {
			Button(action: {
				showDatePicker = true
			}, label: {
				HStack(spacing: 10) {
					Text(
						scheduleInteractor.formatYearMonth(calendarController.yearMonth)
					)
					.font(.pretendard(.bold, size: 22))
					
					Image(.icChevronBottomBlack)
				}
			})
			.foregroundStyle(Color.black)
			
			Spacer()
			
			Text("\(groupName)")
				.font(.pretendard(.bold, size: 20))
			
			Button(action: {
				showGroupInfo = true
			}, label: {
				Image(.icMoreVertical)
			})
		}
		.padding(.top, 15)
		.padding(.leading, 20)
		.padding(.trailing, 8)
	}
	
	private var weekday: some View {
		VStack(alignment: .leading) {
			HStack {
				ForEach(weekdays, id: \.self) { weekday in
					Text(weekday)
						.font(.pretendard(.bold, size: 12))
						.foregroundStyle(Color(.textUnselected))
					
					Spacer()
				}
			}
			.padding(.horizontal, 20)
		}
		.frame(height: 30)
		.background(
			Rectangle()
				.fill(Color.white)
				.shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 8)
		)
	}
	
	private var datePicker: some View {
		NamoAlertView(
			showAlert: $showDatePicker,
			content: AnyView(
				HStack(spacing: 0) {
					Picker("", selection: $pickerCurrentYear) {
						ForEach(2000...2099, id: \.self) {
							Text("\(String($0))년")
								.font(.pretendard(.regular, size: 23))
						}
					}
					.pickerStyle(.inline)
					
					Picker("", selection: $pickerCurrentMonth) {
						ForEach(1...12, id: \.self) {
							Text("\(String($0))월")
								.font(.pretendard(.regular, size: 23))
						}
					}
					.pickerStyle(.inline)
				}
				.frame(height: 154)
			),
			leftButtonTitle: "취소",
			leftButtonAction: {
				pickerCurrentYear = calendarController.yearMonth.year
				pickerCurrentMonth = calendarController.yearMonth.month
			},
			rightButtonTitle: "확인",
			rightButtonAction: {
				calendarController.scrollTo(YearMonth(year: pickerCurrentYear, month: pickerCurrentMonth))
			}
		)
	}
	
	private var groupInfo: some View {
		NamoAlertViewWithTopButton(
			showAlert: $showGroupInfo,
			title: "그룹 정보",
			leftButtonTitle: "닫기",
			leftButtonAction: {},
			rightButtonTitle: "저장",
			rightButtonAction: {
				let result = await moimInteractor.changeMoimName(moimId: moim.groupId, newName: newGroupName)
				// 변경 성공 시
				if result {
					groupName = newGroupName
					return true
				}
				
				return false
			},
			content: AnyView(
				VStack(spacing: 0) {
					HStack {
						Text("그룹명")
							.font(.pretendard(.bold, size: 15))
						
						Spacer()
						
						TextField(groupName , text: $newGroupName)
							.font(.pretendard(.regular, size: 15))
							.foregroundStyle(Color(.mainText))
							.multilineTextAlignment(.trailing)
					}
					.padding(.bottom, 20)
					
					HStack {
						Text("그룹원")
							.font(.pretendard(.bold, size: 15))
						
						Spacer()
						
						Text("\(moim.moimUsers.count) 명")
							.font(.pretendard(.regular, size: 15))
							.foregroundStyle(Color(.mainText))
					}
					.padding(.bottom, 30)
					
					LazyVGrid(columns: gridColumn) {
						ForEach(moim.moimUsers, id: \.userId) { user in
							HStack(spacing: 20) {
								Circle()
									.fill(categoryInteractor.getColorWithPaletteId(id: user.color))
									.frame(width: 20, height: 20)
								
								Text("\(user.userName)")
									.font(.pretendard(.regular, size: 15))
									.foregroundStyle(Color(.mainText))
								
								Spacer(minLength: 0)
							}
						}
					}
					.padding(.bottom, 25)
					
					HStack(spacing: 0) {
						Text("그룹 코드")
							.font(.pretendard(.bold, size: 15))
							.padding(.leading, 29)
						
						Spacer()
						
						Text("\(moim.groupCode)")
							.font(.pretendard(.regular, size: 15))
							.foregroundStyle(Color(.mainText))
							.kerning(3)
						
						Button(action: {}, label: {
							Image(.btnCopy)
						})
						.padding(.trailing, 12)
					}
					.frame(height: 40)
					.frame(maxWidth: .infinity)
					.background(Color(.mainGray))
					.cornerRadius(5)
					.padding(.bottom, 31)
					
					Button(action: {
						Task {
							let result = await moimInteractor.withdrawGroup(moimId: moim.groupId)
							// 탈퇴 성공시 dismiss
							if result {
								appState.isTabbarOpaque = false
								dismiss()
							}
						}
					}, label: {
						Text("탈퇴하기")
							.font(.pretendard(.regular, size: 15))
							.padding(.horizontal, 44)
							.padding(.vertical, 11)
							.overlay(
								RoundedRectangle(cornerRadius: 20)
									.inset(by: 0.5)
									.stroke(.black, lineWidth: 1)
							)
					})
					.tint(.black)
					.padding(.bottom, 30)
				}
					.padding(.top, 25)
			)
		)
		.onDisappear {
			newGroupName = groupName
		}
	}
}

#Preview {
	GroupCalendarView(moim: Moim(groupId: 1, groupName: "123", groupImgUrl: "", groupCode: "", moimUsers: []))
}
