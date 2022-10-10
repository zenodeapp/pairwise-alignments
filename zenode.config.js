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
    nt: "alphabets/nt.txt",
    aa: "alphabets/aa.txt",
  },

  matrices: {
    simple: {
      alphabet: "nt",
      file: "matrices/nt/simple.txt",
    },
    smart: {
      alphabet: "nt",
      file: "matrices/nt/smart.txt",
    },
    blosum50: {
      alphabet: "aa",
      file: "matrices/aa/blosum50.txt",
    },
    blosum62: {
      alphabet: "aa",
      file: "matrices/aa/blosum62.txt",
    },
    pam40: {
      alphabet: "aa",
      file: "matrices/aa/pam40.txt",
    },
    pam120: {
      alphabet: "aa",
      file: "matrices/aa/pam120.txt",
    },
    pam250: {
      alphabet: "aa",
      file: "matrices/aa/pam250.txt",
    },
  },

  contracts: {
    substitutionMatrices: {
      name: "SubstitutionMatrices",
      address: "",
    },
    needlemanWunsch: {
      name: "NeedlemanWunsch",
      address: "0x4631BCAbD6dF18D94796344963cB60d44a4136b6",
    },
  },
};
