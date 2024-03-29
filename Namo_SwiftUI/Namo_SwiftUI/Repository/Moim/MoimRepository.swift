//
//  MoimRepository.swift
//  Namo_SwiftUI
//
//  Created by 정현우 on 2/17/24.
//

import Foundation

protocol MoimRepository {
	func createMoim(groupName: String, image: Data?) async -> createMoimResponse?
	func getMoimList() async -> getMoimListResponse?
	func changeMoimName(data: changeMoimNameRequest) async -> Bool
	func participateMoim(groupCode: String) async -> Bool
	func withdrawMoim(moimId: Int) async -> Bool
}
