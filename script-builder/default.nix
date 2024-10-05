{lib, config, ...}:
{
  utils = {
    colors = {
      black  = "30";
      red    = "31";
      green  = "32";
      brown  = "33";
      blue   = "34";
      purple = "35";
      cyan   = "36";
      gray   = "37";  
    };

    applyColor = color: txt: "\\033[0;${color}m${txt}\\033[0m";

    checkNargs = N: usage: ''
      if [ $# -ne ${N} ]; then
        echo ${usage}
        return
      fi 
    '';

    readFileByIFS = {outArr, IFS, file}: ''
      ${outArr}=()
      IFS=${IFS}
      while read line; do
        ${outArr}+=line
      done < ${file}
      unset IFS
    '';
  };
}