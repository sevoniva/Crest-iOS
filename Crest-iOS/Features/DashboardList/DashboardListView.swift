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
            ZStack {
                List {
                    if viewModel.isLoading && viewModel.nodes.isEmpty {
                        Section {
                            HStack {
                                Spacer()
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                    Text("加载中...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .listRowBackground(Color.clear)
                        }
                    } else if let error = viewModel.errorMessage, viewModel.nodes.isEmpty {
                        Section {
                            ContentUnavailableView {
                                Label("加载失败", systemImage: "exclamationmark.triangle")
                            } description: {
                                Text(error)
                            } actions: {
                                Button("重试") {
                                    Task { await viewModel.load() }
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                    } else {
                        let dashboards = filteredDashboards()
                        if dashboards.isEmpty && !searchText.isEmpty {
                            Section {
                                ContentUnavailableView.search(text: searchText)
                                    .listRowBackground(Color.clear)
                            }
                        } else {
                            Section {
                                ForEach(dashboards) { node in
                                    NavigationLink(value: node) {
                                        DashboardRow(node: node)
                                    }
                                }
                            } header: {
                                Text("我的仪表板 (\(dashboards.count))")
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("工作台")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索仪表板")
            .refreshable {
                await viewModel.refresh()
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
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconBackgroundColor)
                    .frame(width: 48, height: 48)
                
                Image(systemName: iconName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(node.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    if node.mobileLayout == true {
                        Label("移动端", systemImage: "iphone")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                    
                    Text(node.type == "dataV" ? "数据大屏" : "仪表板")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
    
    private var iconName: String {
        if node.type == "dataV" {
            return "tv.fill"
        }
        return "square.grid.2x2.fill"
    }
    
    private var iconColor: Color {
        if node.type == "dataV" {
            return .purple
        }
        return .blue
    }
    
    private var iconBackgroundColor: Color {
        if node.type == "dataV" {
            return .purple.opacity(0.12)
        }
        return .blue.opacity(0.12)
    }
}
