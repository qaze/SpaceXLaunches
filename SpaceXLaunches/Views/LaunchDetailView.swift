import SwiftUI

struct LaunchDetailView: View {
    @StateObject private var viewModel: LaunchDetailViewModel
    
    init(viewModel: LaunchDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let url = viewModel.missionPatch {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let error = viewModel.error {
                        Text("Error: \(error.localizedDescription)")
                            .foregroundColor(.red)
                    } else {
                        VStack(alignment: .leading) {
                            Text("Launch \(viewModel.launch.name)")
                                .font(.headline)
                            
                            if let details = viewModel.launch.details {
                                Text(details)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        if let rocket = viewModel.rocket {
                            VStack(alignment: .leading) {
                                Text("Rocket")
                                    .font(.headline)
                                Text(rocket.name)
                                if let description = rocket.description {
                                    Text(description)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Launch Date")
                        .font(.headline)
                    Text(viewModel.launchDate)
                }
                .padding(.horizontal)
                
                if let videoURL = viewModel.videoURL {
                    Link(destination: videoURL) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Watch Launch Video")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchDetails()
        }
    }
} 
