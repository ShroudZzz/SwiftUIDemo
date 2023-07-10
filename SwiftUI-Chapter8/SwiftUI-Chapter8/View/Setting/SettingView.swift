import SwiftUI

struct SettingView: View {
    @EnvironmentObject var store: Store
    
    var setingsBinding: Binding<AppState.Settings> {
        $store.appState.settings
    }
    
    var settings: AppState.Settings {
        store.appState.settings
    }
    
    var body: some View {
        Form {
            accountSection
            if settings.loginUser != nil {
                optionSection
                actionSection
            }
        }
        .alert(item: setingsBinding.loginError) { error in
            Alert(title: Text(error.localizedDescription))
        }
    }
    
    var accountSection: some View {
        Section(header: Text("账户")) {
            if settings.loginUser == nil {
                Picker(selection: setingsBinding.accountBehavior, label: Text("")) {
                    ForEach(AppState.Settings.AccountBehavior.allCases, id: \.self) {
                        Text($0.text)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                TextField("电子邮箱", text: setingsBinding.email)
                SecureField("密码", text: setingsBinding.password)
                if settings.accountBehavior == .register {
                    SecureField("确认密码", text: setingsBinding.verifyPassword)
                }
                if settings.loginRequesting {
                    Text("Logining....")
                } else {
                    Button(settings.accountBehavior.text) {
                        store.dispatch(.login(email: settings.email, passwd: settings.password))
                    }
                }
            } else {
                Text(settings.loginUser!.email)
                Button("注销") {
                    store.dispatch(.logout)
                }
            }
        }
    }
    
    var optionSection: some View {
        Section(header: Text("选项")) {
            Toggle(isOn: setingsBinding.showEnglishName) {
                Text("显示英文名")
            }
            Picker(selection: setingsBinding.sorting, label: Text("排序方式")) {
                ForEach(AppState.Settings.Sorting.allCases, id: \.self) {
                    Text($0.text)
                }
            }
            Toggle(isOn: setingsBinding.showFavoriteOnly) {
                Text("只显示收藏")
            }
        }
    }
    
    var actionSection: some View {
        Section {
            Button(action: {
                print("清空缓存")
            }) {
                Text("清空缓存").foregroundColor(.red)
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store()
        store.appState.settings.sorting = .color
        //store.appState.settings.loginUser = User(email: "example.com", favoritePokemonIds: [])
        return SettingView().environmentObject(store)
    }
}
