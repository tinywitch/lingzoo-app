import SwiftUI
import Combine

struct CategoriesView: View {
    let language: Language
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoadingCategories {
                ProgressView("Loading Categories...")
            } else if viewModel.rootCategories.isEmpty {
                VStack {
                    Text("No categories found.")
                        .foregroundColor(.gray)
                    if let error = viewModel.errorMessage {
                        Text(error).foregroundColor(.red).font(.caption)
                    }
                }
            } else {
                List(viewModel.rootCategories) { category in
                    NavigationLink(destination: CategoryDetailView(categoryId: category.id, categoryName: category.name)) {
                        HStack {
                            Circle()
                                .fill(colorFromHex(category.color ?? "#000000"))
                                .frame(width: 16, height: 16)
                            Text(category.name)
                                .font(.headline)
                            Spacer()
                            Text("\(category.packs?.count ?? 0) packs")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationTitle(language.name)
        .task {
            if viewModel.rootCategories.isEmpty {
                await viewModel.fetchCategories(for: language.id)
            }
        }
    }
    
    private func colorFromHex(_ hex: String) -> Color {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return Color.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return Color(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}

// Shows sub-categories and packs
struct CategoryDetailView: View {
    let categoryId: String
    let categoryName: String
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoadingCategoryDetails {
                ProgressView("Loading...")
            } else if let details = viewModel.currentCategoryDetails {
                List {
                    if let children = details.children, !children.isEmpty {
                        Section(header: Text("Sub-Categories")) {
                            ForEach(children) { child in
                                NavigationLink(destination: CategoryDetailView(categoryId: child.id, categoryName: child.name)) {
                                    HStack {
                                        Circle()
                                            .fill(colorFromHex(child.color ?? "#000000"))
                                            .frame(width: 12, height: 12)
                                        Text(child.name)
                                    }
                                }
                            }
                        }
                    }
                    
                    if let packs = details.packs, !packs.isEmpty {
                        Section(header: Text("Packs")) {
                            ForEach(packs) { pack in
                                NavigationLink(destination: PackDetailView(packId: pack.id, packName: pack.name)) {
                                    HStack {
                                        if let imageURL = pack.featured_image, let url = URL(string: imageURL) {
                                            AsyncImage(url: url) { image in
                                                image.resizable().scaledToFill().frame(width: 50, height: 50).cornerRadius(8).clipped()
                                            } placeholder: {
                                                Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 50, height: 50).cornerRadius(8)
                                            }
                                        }
                                        Text(pack.name)
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                    }
                    
                    if (details.children?.isEmpty ?? true) && (details.packs?.isEmpty ?? true) {
                        Text("This category is empty.")
                            .foregroundColor(.gray)
                    }
                }
            } else if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            } else {
                Color.clear
            }
        }
        .navigationTitle(categoryName)
        .task {
            await viewModel.fetchCategoryDetails(categoryId: categoryId)
        }
    }
    
    private func colorFromHex(_ hex: String) -> Color {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) { return Color.gray }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return Color(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}
