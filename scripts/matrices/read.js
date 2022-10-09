const fs = require("fs/promises");
const { matrix, matrixVariable } = require("../../proteins.config");

async function main() {
  const res = await fs.readFile(matrix, { encoding: "utf8" });
  console.log(res);

  const test = res.split(/\r?\n/);
  console.log(test);
  test.map((bla, i, row) => {
    const yeah = bla.trim().split(/\s+/);
    // console.log(yeah);
    let str = "[";

    if (i === 1) {
      console.log(
        `int[${yeah.length - 1}][${row.length - 1}] ${matrixVariable} = [`
      );
    }

    yeah.map((letter, j) => {
      if (i === 0) {
        console.log(`proteinMapping["${letter}"] = ${j};`);
      } else if (j > 0) {
        str =
          str +
          (str !== "[" ? ", " : "") +
          (j === 1 ? "int(" : "") +
          letter +
          (j === 1 ? ")" : "");
      }
    });

    str = str + "]" + (i + 1 !== row.length ? "," : "");
    if (str !== "[],") console.log(str);
  });
  console.log("];");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
