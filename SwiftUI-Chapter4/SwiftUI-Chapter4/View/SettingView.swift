import SwiftUI

struct SettingView: View {
    @ObservedObject var settings = Settings()
    
    var body: some View {
        Form {
            accountSection
            optionSection
            actionSection
        }
    }
    
    var accountSection: some View {
        Section(header: Text("账户")) {
            Picker(selection: $settings.accountBehavior) {
                ForEach(Settings.AccountBehavior.allCases, id: \.self) {
                    Text($0.text)
                }
            } label: {
                Text("")
            }
            .pickerStyle(SegmentedPickerStyle())
            
            TextField("电子邮箱", text: $settings.enail)
            SecureField("密码", text: $settings.password)
            
            if settings.accountBehavior == .register {
                SecureField("确认密码", text: $settings.verifyPassword)
            }
            
            Button(settings.accountBehavior.text) {
                print("登录/注册")
            }
        }
    }
    
    var optionSection: some View {
        Section {
            Toggle(isOn: $settings.showEnglishName) {
                Text("显示英文名")
            }
            Picker(selection: $settings.sorting) {
                ForEach(Settings.Sorting.allCases, id: \.self) {
                    Text($0.text)
                }
            } label: {
                Text("排序方式")
            }
            Toggle(isOn: $settings.showFavoriteOnly) {
                Text("只显示收藏")
            }
        } header: {
            Text("选项")
        }
    }
    
    var actionSection: some View {
        Section {
            Button {
                print("清空缓存")
            } label: {
                Text("清空缓存").foregroundColor(.red)
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
