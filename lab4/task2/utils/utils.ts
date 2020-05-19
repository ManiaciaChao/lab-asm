import { createReadStream, fstat, existsSync } from "fs";
import { createInterface } from "readline";
import { promisify } from "util";
import { exec } from "child_process";
import { argv } from "process";

export interface IProcessCallback {
  (line: string, lineNum?: number, totalLineNum?: number): any;
}

export const execute = promisify(exec);

export const mapToObject = map => {
  let object = Object.create(null);
  for (let [k, v] of map) {
    object[k] = v;
  }
  return object;
};

export const normalize = str =>
  str
    ? str
        .replace(/(&amp;)|,|:|-|“|”|\/|\(|\)/g, " ")
        .replace(/  +/g, " ")
        .trim()
        .toLowerCase()
    : undefined;

export async function processByLine(filepath, callback: IProcessCallback) {
  if (!existsSync(filepath)) {
    console.log(`NO FILE ${filepath}!`);
    return;
  }
  const fileStream = createReadStream(filepath);
  let lineNum = 0;
  const rl = createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });

  for await (const line of rl) {
    lineNum++;
    // if (lineNum > 1000) break;
    callback(line, lineNum);
  }
}

export const getSelfFilename = () =>
  argv
    .pop()
    .split("/")
    .pop()
    .split(".")
    .shift();
