const path = require("path");
const express = require("express");
const mongoose = require("mongoose");
const bodyParser = require("body-parser");
const cors = require("cors");
const colors = require("colors");
const promClient = require("prom-client");

const mongooseURI = require("./config/keys").mongoURI;

const userRoutes = require("./routes/user");
const shopRoutes = require("./routes/shop");


const app = express();

const metricsRegister = new promClient.Registry();
promClient.collectDefaultMetrics({ register: metricsRegister, prefix: "nodeapi_" });

const httpRequestDuration = new promClient.Histogram({
  name: "nodeapi_http_request_duration_seconds",
  help: "Duration of HTTP requests in seconds",
  labelNames: ["method", "route", "status_code"],
  registers: [metricsRegister]
});

app.use((req, res, next) => {
  const end = httpRequestDuration.startTimer();
  res.on("finish", () => {
    end({ method: req.method, route: req.path, status_code: res.statusCode });
  });
  next();
});

app.get("/metrics", async (req, res) => {
  res.set("Content-Type", metricsRegister.contentType);
  res.end(await metricsRegister.metrics());
});

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use("/images", express.static(path.join(__dirname, "images")));

app.use(express.static(process.cwd()+"/client/dist/client/"));


app.get('/', (req,res) => {
  res.sendFile(process.cwd()+"/client/dist/client/index.html")
})

app.use("/api/user", userRoutes);
app.use("/api/shop", shopRoutes);


mongoose
  .connect(mongooseURI)
  .then(() => {
    const port = process.env.PORT || 5000;
    const server = app.listen(port, () => {
      console.log("Server running on port".magenta, colors.yellow(port));
    });
    console.log("\nConnected to".magenta, "E-MART".cyan, "database".magenta);
  })
  .catch(err => console.log("Error connecting to database".cyan, err));
