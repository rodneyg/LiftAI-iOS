//
//  CameraPicker.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

// Features/Capture/CameraPicker.swift
import SwiftUI

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onImage: (UIImage) -> Void

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.onImage(img)
            }
            DispatchQueue.main.async { self.parent.isPresented = false }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            DispatchQueue.main.async { self.parent.isPresented = false }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let c = UIImagePickerController()
        c.sourceType = .camera
        c.delegate = context.coordinator
        return c
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
