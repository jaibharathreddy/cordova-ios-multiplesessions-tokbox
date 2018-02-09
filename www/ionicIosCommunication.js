var exec = require('cordova/exec');

exports.coolMethod = function (arg0, success, error) {
    console.log("hai u entered in this plugin ");
    exec(success, error, 'ionicIosCommunication', 'coolMethod', [arg0]);
};
