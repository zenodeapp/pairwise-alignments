# TODO (OPTIONAL) - CONVERT THIS JS TO AWK

# const fs = require("fs/promises");
# const { matrices } = require("../../zenode.config");

# async function main() {
#   const file = await fs.readFile(matrices[0].file, { encoding: "utf8" });

#   file.split(/\r?\n/).map((line, i, row) => {
#     const splittedLine = line.trim().split(/\s+/);

#     if (i === 1) {
#       console.log();
#       console.log(
#         `int[${splittedLine.length - 1}][${row.length - 1}] matrix = [`
#       );
#     }
#     let result = "[";
#     splittedLine.map((char, j) => {
#       if (i === 0) {
#         console.log(`alphabet["${char}"] = ${j};`);
#       } else if (j > 0) {
#         result = `${result}${result !== "[" ? ", " : ""}${
#           j === 1 ? "int(" : ""
#         }${char}${j === 1 ? ")" : ""}`;
#       }
#     });

#     result = `${result}]${i + 1 !== row.length ? "," : ""}`;
#     if (result !== "[],") console.log(result);
#   });
#   console.log("];");
# }

# main().catch((error) => {
#   console.error(error);
#   process.exitCode = 1;
# });
