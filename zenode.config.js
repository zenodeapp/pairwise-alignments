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
      address: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
    },
    needlemanWunsch: {
      name: "NeedlemanWunsch",
      address: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
    },
  },
};
