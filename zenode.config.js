module.exports = {
  alphabetToInsert: ["aa", "nt"], //either give a string value or array
  alphabetToDelete: ["aa", "nt"],
  matrixToInsert: [
    "simple",
    "smart",
    "blosum50",
    "blosum62",
    "pam40",
    "pam120",
    "pam250",
  ],
  matrixToDelete: [
    "simple",
    "smart",
    "blosum50",
    "blosum62",
    "pam40",
    "pam120",
    "pam250",
  ],

  alphabets: {
    nt: "datasets/alphabets/nt.txt",
    aa: "datasets/alphabets/aa.txt",
  },

  matrices: {
    simple: {
      alphabet: "nt",
      file: "datasets/matrices/nt/simple.txt",
    },
    smart: {
      alphabet: "nt",
      file: "datasets/matrices/nt/smart.txt",
    },
    blosum50: {
      alphabet: "aa",
      file: "datasets/matrices/aa/blosum50.txt",
    },
    blosum62: {
      alphabet: "aa",
      file: "datasets/matrices/aa/blosum62.txt",
    },
    pam40: {
      alphabet: "aa",
      file: "datasets/matrices/aa/pam40.txt",
    },
    pam120: {
      alphabet: "aa",
      file: "datasets/matrices/aa/pam120.txt",
    },
    pam250: {
      alphabet: "aa",
      file: "datasets/matrices/aa/pam250.txt",
    },
  },

  contracts: {
    substitutionMatrices: {
      name: "SubstitutionMatrices",
      address: "0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0",
    },
    needlemanWunsch: {
      name: "NeedlemanWunsch",
      address: "0x4ed7c70F96B99c776995fB64377f0d4aB3B0e1C1",
      parameters: {
        _matricesAddress: "0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0",
      },
    },
  },
};
