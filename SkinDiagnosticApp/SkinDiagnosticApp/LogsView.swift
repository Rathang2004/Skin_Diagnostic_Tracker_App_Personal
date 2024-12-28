import SwiftUI
import UIKit

struct LogsView: View {
    var selectedImage: UIImage?
    @State var comment: String  // State variable to store the diagnosis
    @State private var isLoading = false  // To show a loading spinner while the request is being made

    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 256, height: 256)
                    .scaledToFit()
            } else {
                Text("LOGS")
                    .padding(.top, -300)
                    .font(.largeTitle)
                    .bold()
                Text("Past Skin Diagnosis Evaluations")
            }
            
            if isLoading {
                ProgressView("Diagnosing...")  // Show a loading spinner
            } else {
                Text(comment)  // Display the diagnosis once it's fetched
                    .padding(.top, 10)
            }
        }
        .onAppear {
            // Trigger the POST request when the view appears
            if let image = selectedImage {
                diagnoseSkin(image: image)
            } else {
                comment = "No image selected for diagnosis."
            }

        }
    }

    func diagnoseSkin(image: UIImage) {
        isLoading = true
        
        // Convert the image to JPEG data for upload
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            comment = "Failed to process image."
            isLoading = false
            return
        }
        
        let url = URL(string: "http://127.0.0.1:3000/diagnose" )!
                      //"" "https://skin-diagnostic-tracker-server.onrender.com/diagnose"// Update with your actual local link
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let imageFieldName = "image"
        let fileName = "image.jpg"
        let mimeType = "image/jpeg"

 
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"\(imageFieldName)\"; filename=\"\(fileName)\"\r\n".utf8))
        body.append(Data("Content-Type: \(mimeType)\r\n\r\n".utf8))
        body.append(imageData)  // Append the image data directly
        body.append(Data("\r\n".utf8))
        body.append(Data("--\(boundary)--\r\n".utf8))

        request.httpBody = body
        
        // Make the POST request
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.comment = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.comment = "No data received from the server."
                }
                return
            }
            
            if let rawResponse = String(data: data, encoding: .utf8) {
                        print("Raw response: \(rawResponse)")  // Print the raw response
                    }
            

            do {
                let response = try JSONDecoder().decode(DiagnosisResponse.self, from: data)
                DispatchQueue.main.async {
                    self.comment = "Diagnosis: \(response.diagnosisClass) (Class Number: \(response.diagnosisClassNumber))"
                }
            } catch {
                DispatchQueue.main.async {
                    self.comment = "Failed to decode the response."
                }
            }
        }.resume()
    }

}

struct DiagnosisResponse: Decodable {
    var diagnosisClass: String
    var diagnosisClassNumber: Int

    enum CodingKeys: String, CodingKey {
        case diagnosisClass = "Diagnosis Class"
        case diagnosisClassNumber = "Diagnosis Class Number"
    }
}


#Preview {
    LogsView(selectedImage: nil, comment: "")
}
