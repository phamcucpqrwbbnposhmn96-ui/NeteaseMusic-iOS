import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var player: PlayerManager

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("首页")
                    }

                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("搜索")
                    }

                LibraryView()
                    .tabItem {
                        Image(systemName: "music.note.list")
                        Text("音乐库")
                    }

                RadioView()
                    .tabItem {
                        Image(systemName: "radio")
                        Text("电台")
                    }

                ListenTogetherView()
                    .tabItem {
                        Image(systemName: "person.2.fill")
                        Text("一起听")
                    }
            }

            VStack(spacing: 0) {
                Spacer()
                MiniPlayerView()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8 + (player.currentSong != nil ? 49 : 0))
                    .offset(y: player.currentSong == nil ? 200 : 0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: player.currentSong != nil)
            }
            .ignoresSafeArea(.keyboard)
        }
        .sheet(isPresented: $player.isExpanded) {
            FullPlayerView()
        }
    }
}
