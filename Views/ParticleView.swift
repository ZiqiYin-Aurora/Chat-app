//
//  ParticleGalaxy.swift
//  Chatting
//
//  Created by Yin Celia on 2021/12/2.
//

import SwiftUI
import UIKit

class JointViewController: UIViewController, ParticleAnimationable {
    var delegate : ParticleViewDelegate?
    // number of desired amount
    public var desiredGoal: Int = 0
    public var finishFlag = false
    public var successCount = 0
    public var sender: Bool = true
    
    // MARK: - View Controller Life Cycle
    func actionClick() {
        let rect = CGRect(x: 500.0, y: 500.0, width: view.bounds.width, height: 800)
        let point = CGPoint(x: rect.width/2, y: rect.height/2)
        sender ? startParticleAnimation(point) : stopParticleAnimation()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

protocol ParticleViewDelegate: NSObjectProtocol {
    func ParticleViewDidFinished(_ viewController: JointViewController)
    func OneGroupDidFinished(_ viewController: JointViewController)
    func ConfirmDesiredGoal(_ viewController: JointViewController)
}

struct ParticleView: UIViewControllerRepresentable {
    @Binding var isBegin: Bool
    @Binding var isFinished: Bool
    @Binding var desiredGoal: Int
    @Binding var currentNum: Int
    @Binding var sender: Bool

    // Init your ViewController
    func makeUIViewController(context: Context) -> JointViewController {
        let controller = JointViewController()
        controller.sender = sender
        controller.actionClick()
        return controller
    }

    func updateUIViewController(_ uiViewController: JointViewController, context: Context) {
    }

    func makeCoordinator() -> ParticleView.Coordinator {
        return Coordinator(isFinished: $isFinished, currentNum: $currentNum, desiredGoal: $desiredGoal, sender: $sender)
    }
}

extension ParticleView {
    class Coordinator: NSObject, ParticleViewDelegate {

        @Binding var isFinished: Bool
        @Binding var currentNum: Int
        @Binding var desiredGoal: Int
        @Binding var sender: Bool

        init(isFinished: Binding<Bool>, currentNum: Binding<Int>, desiredGoal: Binding<Int>, sender: Binding<Bool>) {
            _isFinished = isFinished
            _currentNum = currentNum
            _desiredGoal = desiredGoal
            _sender = sender
        }

        func ParticleViewDidFinished(_ viewController: JointViewController) {
            isFinished = viewController.finishFlag
        }

        func OneGroupDidFinished(_ viewController: JointViewController) {
            currentNum = viewController.successCount
        }

        func ConfirmDesiredGoal(_ viewController: JointViewController) {
            viewController.desiredGoal = desiredGoal
        }
    }
}

