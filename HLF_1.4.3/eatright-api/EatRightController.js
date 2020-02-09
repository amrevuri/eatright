var express = require("express");
var router = express.Router();
var bodyParser = require("body-parser");

router.use(bodyParser.urlencoded({ extended: true }));
router.use(bodyParser.json());

const txSubmit = require("./invoke");
const txFetch = require("./query");

// Record Fish
router.post("/recordFish", async function(req, res) {
  try {
    let result = await txSubmit.invoke("recordFish", JSON.stringify(req.body));
    res.send(result);
  } catch (err) {
    res.status(500).send(err);
  }
});

// Certify Fish 
router.post("/certifyFish", async function(req, res) {
  try {
    let result = await txSubmit.invoke("certifyFish", JSON.stringify(req.body));
    res.send(result);
  } catch (err) {
    res.status(500).send(err);
  }
});

//Load Fish 
router.post("/loadFish", async function(req, res) {
  try {
    let result = await txSubmit.invoke("loadFish", JSON.stringify(req.body));
    res.send(result);
  } catch (err) {
    res.status(500).send(err);
  }
});

//Deliver Fish 
router.post("/deliverFish", async function(req, res) {
  try {
    let result = await txFetch.query("deliverFish", req.body.fishId);
    res.send(JSON.parse(result));
  } catch (err) {
    res.status(500).send(err);
  }
});

// Acknowledge Delivery 
router.post("/ackDelivery", async function(req, res) {
  try {
    let result = await txFetch.query("ackDelivery", req.body.fishId);
    res.send(JSON.parse(result));
  } catch (err) {
    res.status(500).send(err);
  }
});

// Get Fish Delivery history
router.post("/getDeliveryHistory", async function(req, res) {
  try {
    let result = await txFetch.query("getDeliveryHistory", req.body.fishId);
    res.send(JSON.parse(result));
  } catch (err) {
    res.status(500).send(err);
  }
});

// Get Fish History
router.post("/getFish", async function(req, res) {
  try {
    let result = await txFetch.query("getFish", req.body.fishId);
    res.send(JSON.parse(result));
  } catch (err) {
    res.status(500).send(err);
  }
});

module.exports = router;
