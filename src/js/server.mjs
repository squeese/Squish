import express from 'express';
import { readdir } from 'fs';

export default () => {
  const app = express();
  const port = 8081;
  app.use(express.static("./SquishSCan/data"));
  app.get("/list", (req, res) => {
    readdir("./SquishScan/data/", (err, files) => {
      if (err) return res.json([]);
      res.json(files);
    })
  });
  app.listen(port, () => `http://localhost:${port}/`);
};
