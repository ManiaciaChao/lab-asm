import { processByLine } from "./utils";

const shuffle = (src: Array<any>) => {
  const res = Array.from(src);
  for (let i = res.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [res[i], res[j]] = [res[j], res[i]];
  }
  return res;
};

const regex = {
  blank: /^\s*$/,
  label: /^.+:\s*;?.*$/,
  comment: /^\s*;.+$/,
};

const file = "./input.txt";
const startFrom = 89;

(async () => {
  const codes = [] as string[];
  let codeBuffer = "";
  let dingling = false;
  await processByLine(file, (line, lineNum) => {
    if (regex.blank.test(line)) {
      return;
    }
    if (regex.label.test(line) || regex.comment.test(line)) {
      codeBuffer += line + "\n";
      dingling = true;
      return;
    }
    if (dingling) {
      codeBuffer += line;
      dingling = false;
      codes.push(codeBuffer);
      codeBuffer = "";
    } else {
      codes.push(line);
    }
  });
  let i = 0;
  const mark = [] as number[];
  const codesWithJmp = codes.map((code, index) => {
    if (code.includes("proc") || code.includes("endp")) {
      mark.push(index);
      return code;
    }
    let res = `obfs_${i + startFrom} label far\n${code}`;

    if (
      index + 2 !== codes.length &&
      !codes[index + 1].includes("proc") &&
      !codes[index + 1].includes("endp")
    ) {
      res += `\njmp far ptr obfs_${i + startFrom + 1}`;
    }
    i++;
    return res;
  });
  let n = mark.length;
  let res = [] as string[];
  while (mark.length) {
    const start = mark.shift();
    const end = mark.shift();
    const part = codesWithJmp.slice(start + 2, end);
    res = [
      ...res,
      codesWithJmp[start],
      codesWithJmp[start + 1],
      ...shuffle(part),
      codesWithJmp[end],
    ];
  }
  console.log(res.join("\n"));
})();

// (async () => {
//   const codes = [] as string[];
//   let codeBuffer = "";
//   let dingling = false;
//   await processByLine(file, (line, lineNum) => {
//     if (regex.label.test(line) || regex.comment.test(line)) {
//       codeBuffer += line + "\n";
//       dingling = true;
//       return;
//     }
//     if (dingling) {
//       codeBuffer += line;
//       dingling = false;
//       codes.push(codeBuffer);
//       codeBuffer = "";
//     } else {
//       codes.push(line);
//     }
//   });
//   const codesWithJmp = codes.map((code, i) => {
//     let res = `obfs_${i + startFrom} label far\n${code}`;
//     if (i !== codes.length - 1) {
//       res += `\njmp far ptr obfs_${i + startFrom + 1}`;
//     }
//     return res;
//   });
//   console.log(shuffle(codesWithJmp).join("\n"));
//   console.log(codes.length + startFrom);
// })();
