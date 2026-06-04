import SwiftUI

struct DashboardListView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: DashboardListViewModel
    @State private var searchText = ""
    
    init(token: String) {
        _viewModel = State(initialValue: DashboardListViewModel(token: token))
    }
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading && viewModel.nodes.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView {
                        Label("加载失败", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("重试") {
                            Task { await viewModel.load() }
                        }
                    }
                } else {
                    let dashboards = filteredDashboards()
                    if dashboards.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else {
                        ForEach(dashboards) { node in
                            NavigationLink(value: node) {
                                DashboardRow(node: node)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("工作台")
            .searchable(text: $searchText, prompt: "搜索仪表板")
            .refreshable {
                await viewModel.load()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        Image(systemName: "person.circle")
                            .font(.title3)
                    }
                }
            }
            .navigationDestination(for: DashboardNode.self) { node in
                DashboardDetailView(token: appState.token ?? "", node: node)
            }
        }
        .task {
            await viewModel.load()
        }
    }
    
    private func filteredDashboards() -> [DashboardNode] {
        let dashboards = viewModel.flattenedNodes()
        if searchText.isEmpty {
            return dashboards
        }
        return dashboards.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}

struct DashboardRow: View {
    let node: DashboardNode
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(node.name)
                    .font(.body)
                    .lineLimit(1)
                
                if node.mobileLayout == true {
                    Text("支持移动端")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var iconName: String {
        if node.type == "dataV" {
            return "tv.fill"
        }
        return "square.grid.2x2"
    }
}
