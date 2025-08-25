//
//  LibraryPicker.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI
import PhotosUI

struct LibraryPicker: UIViewControllerRepresentable {
    var selectionLimit: Int
    var onImages: ([UIImage]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = selectionLimit
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: LibraryPicker
        init(_ parent: LibraryPicker) { self.parent = parent }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard !results.isEmpty else { picker.dismiss(animated: true); return }
            var uiImages: [UIImage] = []
            let group = DispatchGroup()
            for r in results {
                if r.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    group.enter()
                    r.itemProvider.loadObject(ofClass: UIImage.self) { obj, _ in
                        if let img = obj as? UIImage { uiImages.append(img) }
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main) {
                self.parent.onImages(uiImages)
                picker.dismiss(animated: true)
            }
        }
    }
}
