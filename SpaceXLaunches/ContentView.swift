
import SwiftUI

struct ContentView: View {
    var body: some View {
        LaunchListView(
            viewModel: LaunchListViewModel(
                launchService: LaunchesServiceImpl(
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
    }
}

#Preview {
    ContentView()
}
