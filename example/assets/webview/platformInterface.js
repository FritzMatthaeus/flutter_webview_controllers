const PlatformEvents = {
  ON_GO_BACK: "goBack",
  ON_RESUME: "onResume",
  ON_PAUSE: "onPause",
};

class PlatformInterface {
  /**
   * @type {boolean}
   */
  isInitalized = false;

  /**
   * @type {CustomEventEmitter}
   */
  listen = new CustomEventEmitter();

  /**
   * An array of functions that have been called
   * before the Flutter Interface is initialized
   *
   * they are stacked and executed when the Flutter Interface is initialized
   * @type {Array<Function>}
   */
  stackedCalls = [];

  constructor() {
    this.isInitalized = true;
  }

  async isAndroid() {
    return (await this.getPlatform()) == "android" ? true : false;
  }

  async isIOS() {
    return (await this.getPlatform()) == "ios" ? true : false;
  }

  async isWeb() {
    return (await this.getPlatform()) == "web" ? true : false;
  }

  /**
   * returns the platform of the device from Flutter
   * @return {Promise<string>}
   * @memberof PlatformInterface
   */
  async getPlatform() {
    return "web";
  }

  /**
   * emits NativeEvents.ON_RESUME
   * is fired when App comes from background
   * [Android, iOS]
   * @memberof PlatformInterface
   */
  onResume() {
    console.log("onResume");
    this.listen.emit(PlatformEvents.ON_RESUME);
  }

  /**
   * emits NativeEvents.ON_PAUSE
   * is fired when App goes to background
   * [Android, iOS]
   * @memberof PlatformInterface
   */
  onPause() {
    console.log("onPause");
    this.listen.emit(PlatformEvents.ON_PAUSE);
  }

  /**
   * emits NativeEvents.GO_BACK
   * is fired when Android Back Button is tapped
   * [Android]
   * @memberof PlatformInterface
   */
  onGoBack() {
    console.log("goBack");
    this.listen.emit(PlatformEvents.ON_GO_BACK);
  }

  /**
   * await this method to get the FirebaseToken
   * returns "dummyToken" if not called on Flutter Interface
   * and is resolved on success
   * @return {Promise<string>}
   * @memberof PlatformInterface
   */
  async getFirebaseToken() {
    return new Promise((resolve) => resolve("dummyToken"));
  }

  /**
   * opens the phone app with the given phone number
   * does nothing if not called on Flutter Interface
   * [Android, iOS]
   * @param {string} phoneNumber
   * @memberof PlatformInterface
   */
  openPhone(phoneNumber) {
    console.log("openPhone: " + phoneNumber);
  }
}

class FlutterInterface extends PlatformInterface {
  constructor() {
    super();
    this.isInitalized = false;
    window.addEventListener("flutterInAppWebViewPlatformReady", async () => {
      this.isInitalized = true;
      console.log("FlutterInterface initialized");
      // this.platform = await this.getPlatform();
      this.stackedCalls.forEach((call) => call());
      this.stackedCalls = [];
    });
  }

  /**
   * @override
   */
  async getPlatform() {
    return window.flutter_inappwebview.callHandler("getPlatform");
  }

  /**
   * @override
   */
  openPhone(phoneNumber) {
    if (this.isInitalized) {
      window.flutter_inappwebview.callHandler("openPhone", phoneNumber);
    } else {
      this.stackedCalls.push(() => this.openPhone(phoneNumber));
    }
  }

  /**
   * @override
   */
  async getFirebaseToken() {
    if (this.isInitalized) {
      return window.flutter_inappwebview.callHandler("getFirebaseToken");
    } else {
      return new Promise((resolve) =>
        this.stackedCalls.push(() => resolve(this.getFirebaseToken()))
      );
    }
  }
}

/**
 * @type {PlatformInterface}
 */
var platformInterface = null;

if (typeof window.flutter_inappwebview != "undefined") {
  console.log("Instantiating FlutterInterface");
  platformInterface = new FlutterInterface();
} else {
  console.log("Instantiating PlatformInterface");
  platformInterface = new PlatformInterface();
}
