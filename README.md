# GiphySearch

An single-screen app that implements a paginating UITableView displaying GIFs retrieved from Giphy's public API.

The app shows a list of the top trending GIFs by default, and has an option to search for anything you please. The app is built using the MVVM architecture, facilitated by [RxSwift](https://github.com/ReactiveX/RxSwift) and [Moya](https://github.com/Moya/Moya). It uses [SDWebImage](https://github.com/rs/SDWebImage) and [FLAnimatedImage](https://github.com/Flipboard/FLAnimatedImage) for image caching and performant GIF displaying.

## Installation Instructions
Run the following commands to download the repository and open the project in Xcode.
```
git clone git@github.com:Killectro/GiphySearch.git
cd GiphySearch/GiphySearch
pod install
open GiphySearch.xcworkspace
```