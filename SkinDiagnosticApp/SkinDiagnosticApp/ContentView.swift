//
//  ContentView.swift
//  SkinDiagnosticApp
//
//  Created by Rathang Pandit on 11/16/24.
//
import SwiftUI
import UIKit

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var showActionSheet = false
    @State private var showImagePicker = false
    @State private var selected = false
    @State private var filled = false
    @State private var comment = ""
    @State private var useCamera = false
    @State private var navigateToLogsView = false // New state to control navigation
    
    var body: some View {
        NavigationView {
            VStack {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 256, height: 256)
                        .onAppear {
                            self.selected = true
                        }
                        .padding(.top, 20)
                } else {
                    Text("No Image Selected")
                        .frame(width: 256, height: 256)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.top, 20)
                }
                
                Text("Comments")
                    .font(.headline)
                    .padding(.top, 20)
                
                TextField("Description", text: $comment)
                    .onChange(of: comment) { newValue in
                        self.filled = !newValue.isEmpty
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                
                Spacer()
                
                Button("Choose or Take an Image") {
                    showActionSheet = true
                }
                .padding()
                .actionSheet(isPresented: $showActionSheet) {
                    getActionSheet()
                }
                
                Button("Save") {
                    if selected && filled {
                        navigateToLogsView = true
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background((selected && filled) ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .disabled(!selected || !filled)
                .padding(.bottom, 20)
                
                NavigationLink(
                    destination: LogsView(selectedImage: selectedImage, comment: comment),
                    isActive: $navigateToLogsView // Use the new state here
                ) {
                    EmptyView()
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage, useCamera: useCamera)
            }
            .navigationBarTitle("Skin Diagnostic", displayMode: .inline)
            .padding()
        }
    }
    
    func getActionSheet() -> ActionSheet {
        ActionSheet(
            title: Text("Select a Picture"),
            buttons: [
                .default(Text("Take a Picture")) {
                    useCamera = true
                    showImagePicker = true
                },
                .default(Text("Choose a Picture")) {
                    useCamera = false
                    showImagePicker = true
                },
                .cancel()
            ]
        )
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage? // Binding to pass image back
    var useCamera: Bool                  // Determine source type (camera/library)
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = useCamera ? .camera : .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}


#Preview {
    ContentView()
}
