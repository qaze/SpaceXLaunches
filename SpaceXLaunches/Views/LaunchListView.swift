import SwiftUI

struct LaunchListView: View {
    @StateObject private var viewModel: LaunchListViewModel
    
    init(viewModel: LaunchListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.error {
                    VStack {
                        Text("Error loading launches")
                            .foregroundColor(.red)
                        Text(error.localizedDescription)
                            .font(.caption)
                        Button("Retry") {
                            Task {
                                await viewModel.fetchLaunches()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    List(viewModel.launches) { launch in
                        NavigationLink {
                            LaunchDetailView(
                                viewModel: LaunchDetailViewModel(
                                    launch: launch,
                                    rocketService: RocketServiceImpl(
                                        apiClient: APIClientImpl(
                                            session: URLSession.shared,
                                            requestBuilder: URLRequestBuilderImpl()
                                        ),
                                        cache: CacheServiceImpl(
                                            cachePathBuilder: CachePathBuilderImpl(
                                                fileManager: FileManager.default
                                            ),
                                            jsonFileCoder: JSONFileCoderImpl()
                                        )
                                    )
                                )
                            )
                        } label: {
                            LaunchRow(launch: launch)
                        }
                    }
                }
            }
            .navigationTitle("SpaceX Launches")
        }
        .task {
            await viewModel.fetchLaunches()
        }
    }
}

struct LaunchRow: View {
    let launch: Launch
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(launch.name)
                .font(.headline)
            Text(launch.dateUTC, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
} 
