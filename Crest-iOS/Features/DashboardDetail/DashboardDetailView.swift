import SwiftUI

struct DashboardDetailView: View {
    let token: String
    let node: DashboardNode
    
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showError = false
    
    private var previewURL: URL {
        let base = "https://crest.sevoniva.com"
        let path = node.type == "dataV" ? "/previewShow" : "/preview"
        return URL(string: "\(base)\(path)?dvId=\(node.id)&mobile=true")!
    }
    
    var body: some View {
        ZStack {
            CrestPreviewWebView(url: previewURL, token: token)
                .ignoresSafeArea(edges: .bottom)
            
            if isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("加载中...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground).opacity(0.9))
            }
        }
        .navigationTitle(node.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isLoading = true
                    errorMessage = nil
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .alert("加载失败", isPresented: $showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "网络错误")
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
    }
}
