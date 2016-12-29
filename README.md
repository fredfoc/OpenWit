# OpenWit

[![Version](https://img.shields.io/cocoapods/v/OpenWit.svg?style=flat)](http://cocoapods.org/pods/OpenWit)
[![License](https://img.shields.io/cocoapods/l/OpenWit.svg?style=flat)](http://cocoapods.org/pods/OpenWit)
[![Platform](https://img.shields.io/cocoapods/p/OpenWit.svg?style=flat)](http://cocoapods.org/pods/OpenWit)

This Pod is an intent to get a swift framework for Wit.ai© HTTP API.


You can find more information about Wit© on: https://wit.ai and https://wit.ai/docs/http/20160526
Wit© is an amazing NLP api where you can define stories (at the time of this writing they are in beta). Wit© does speech recognition, converse, message analyse, can learn to understand what you want and many more things.


This library is a first version where you can analyse a message and converse (speech is actually not fully implemented but should be soon). It requires Moya and ObjectMapper.

You can find some informations about how the Wit application is structured in the WitData folder.

Those tests are not really sexy but they work and that was the first intent of this version. Better things soon.

![Test Converse](WitData/test_converse.png?raw=true "Test Converse") ![Test Message](WitData/test_message.png?raw=true "Test Converse")

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. You can find first attemps in ViewController.swift

## Requirements

## Installation

OpenWit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "OpenWit"
```

## Author

fauquette fred, fredfocmac@gmail.com

## License

OpenWit is available under the MIT license. See the LICENSE file for more info.
