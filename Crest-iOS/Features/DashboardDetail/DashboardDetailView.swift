import SwiftUI

struct DashboardDetailView: View {
    let token: String
    let node: DashboardNode
    
    @State private var viewModel: DashboardDetailViewModel
    
    init(token: String, node: DashboardNode) {
        self.token = token
        self.node = node
        _viewModel = State(initialValue: DashboardDetailViewModel(token: token, nodeId: node.id))
    }
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 300)
            } else if let error = viewModel.errorMessage, viewModel.detail == nil {
                ContentUnavailableView {
                    Label("加载失败", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error)
                } actions: {
                    Button("重试") {
                        Task { await viewModel.load() }
                    }
                }
            } else if let detail = viewModel.detail {
                VStack(spacing: 16) {
                    ForEach(detail.componentData ?? []) { component in
                        ComponentView(component: component, token: token)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(node.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.load() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

struct ComponentView: View {
    let component: ComponentData
    let token: String
    
    var body: some View {
        Group {
            switch component.component {
            case "UserView":
                ChartComponentView(component: component, token: token)
            case "Picture":
                ImageComponentView(component: component)
            case "VText":
                TextComponentView(component: component)
            default:
                PlaceholderComponentView(component: component)
            }
        }
        .frame(
            width: CGFloat(component.style?.width ?? 300),
            height: CGFloat(component.style?.height ?? 200)
        )
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ChartComponentView: View {
    let component: ComponentData
    let token: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = component.viewInfo?.title {
                Text(title)
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
            }
            
            ChartWebView(chartHTML: generateChartScript())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func generateChartScript() -> String {
        let chartId = component.viewInfo?.id ?? component.id
        return """
        var chart = echarts.init(document.getElementById('chart-container'));
        chart.setOption({
            title: { text: '\(component.viewInfo?.title ?? "")', textStyle: { fontSize: 14 } },
            tooltip: { trigger: 'axis' },
            grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
            xAxis: { type: 'category', data: ['A', 'B', 'C', 'D', 'E'] },
            yAxis: { type: 'value' },
            series: [{ data: [120, 200, 150, 80, 70], type: 'bar' }]
        });
        """
    }
}

struct ImageComponentView: View {
    let component: ComponentData
    
    var body: some View {
        AsyncImage(url: URL(string: component.propValue?.url ?? "")) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fit)
            case .failure:
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            @unknown default:
                EmptyView()
            }
        }
    }
}

struct TextComponentView: View {
    let component: ComponentData
    
    var body: some View {
        Text(component.propValue?.text ?? "")
            .font(.body)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct PlaceholderComponentView: View {
    let component: ComponentData
    
    var body: some View {
        VStack {
            Image(systemName: "cube")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(component.component)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
