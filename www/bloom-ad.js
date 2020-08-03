cordova.define("cordova-plugin-bloom-ad.BloomAd", function(require, exports, module) {
var exec = require('cordova/exec')

module.exports = {
	setUserId : function (userId) {
		exec(null, null, "BloomAd", "setUserId", [userId])
	},
	showRewardVideoAd : function (params, callback) {
		exec(callback, null, "BloomAd", "showRewardVideoAd", [params.unitId])
	},
	loadBannerAd : function (params, callback) {
		exec(callback, null, "BloomAd", "loadBannerAd", [params.unitId, params.margins])
	},
	showBannerAd : function (params, callback) {
		exec(callback, null, "BloomAd", "showBannerAd", [params.unitId, params.layout, params.margins])
	},
	destroyBannerAd : function (params) {
	    exec(null, null, "BloomAd", "destroyBannerAd", [params.unitId])
	},
	showInterstitialAd : function (params, callback) {
		exec(callback, null, "BloomAd", "showInterstitialAd", [params.unitId])
	}
}
});
