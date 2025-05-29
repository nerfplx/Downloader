import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject private var viewModel = VideoClipViewModel()
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image("cubs")
                        .padding(24)
                    inputSection
                    actionSection
                    
                    if viewModel.isLoading {
                        loadingSection
                    }
                    
                    if let tempURL = viewModel.tempVideoURL {
                        
                        videoSection(url: tempURL)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        errorSection(message: errorMessage)
                    }
                }
                .padding()
            }
            .navigationTitle("Welcome to Black Loader")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var inputSection: some View {
        VStack(spacing: 16) {
            CustomTextField(
                title: "Ссылка на видео",
                text: $viewModel.videoURL,
                placeholder: "https://example.com/video.mp4"
            )
            
            HStack(spacing: 12) {
                CustomTextField(
                    title: "Начало",
                    text: $viewModel.startTime,
                    placeholder: "00:30"
                )
                
                CustomTextField(
                    title: "Конец",
                    text: $viewModel.endTime,
                    placeholder: "01:30"
                )
            }
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: 12) {
            AnimatedButtonView(title: "Скачать фрагмент", action: {
                viewModel.downloadClip()
            }, isEnabled: viewModel.canDownload)
            
            if viewModel.videoData != nil {
                HStack(spacing: 12) {
                    AnimatedButtonView(title: "Сохранить", action: {
                        viewModel.saveVideo()
                    })
                    
                    AnimatedButtonView(title: "Очистить", action: {
                        viewModel.clearData()
                    })
                }
            }
        }
    }
    
    private var loadingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Загружаем видео...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private func videoSection(url: URL) -> some View {
        VStack(spacing: 12) {
            Text("Предварительный просмотр")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VideoPlayer(player: AVPlayer(url: url))
                .frame(height: 250)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
    
    private func errorSection(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .foregroundColor(.red)
                .font(.callout)
        }
        .padding()
        .background(.red.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    ContentView()
}
