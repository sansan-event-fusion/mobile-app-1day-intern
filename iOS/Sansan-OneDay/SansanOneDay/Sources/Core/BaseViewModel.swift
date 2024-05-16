//
//  BaseViewModel.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/02.
//

import Combine
import Foundation

protocol InputType {}
protocol OutputType {}
protocol StateType {}
protocol DependencyType {}

protocol ViewModelType: AnyObject {
    associatedtype Input: InputType
    associatedtype Output: OutputType
    associatedtype State: StateType
    associatedtype Dependency: DependencyType

    static func bind(input: Input, state: State, dependency: Dependency, cancellables: inout Set<AnyCancellable>) -> Output
}

/// MVVMにおけるViewModelの構成を統一するためのクラス
typealias BaseViewModel<ViewModel: ViewModelType> = PrimitiveBaseViewModel<ViewModel> & ViewModelType

class PrimitiveBaseViewModel<ViewModel: ViewModelType> {
    var input: ViewModel.Input
    var output: ViewModel.Output

    private let state: ViewModel.State
    private let dependency: ViewModel.Dependency
    private var cancellables = Set<AnyCancellable>()

    init(input: ViewModel.Input, state: ViewModel.State, dependency: ViewModel.Dependency) {
        self.input = input
        self.output = ViewModel.bind(input: input, state: state, dependency: dependency, cancellables: &cancellables)
        self.state = state
        self.dependency = dependency
    }
}
