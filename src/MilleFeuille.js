const MilleFeuille = require("@frenchpastries/millefeuille");

exports.createImpl = (options) => (handler) => () => {
  return MilleFeuille.create(handler, options);
};

exports.stopImpl = (server) => () => {
  return MilleFeuille.stop();
};
