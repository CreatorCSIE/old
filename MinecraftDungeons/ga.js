function check1(){
var password = document.getElementById("CheatHack").value;
if(password == "cheatshadbug"){
    return true;
}
else{
    if(password=''|| password==null){
       alert("请必须输入密码");
       return false;
    }
    alert("密码错误，请查证后再下载");
    return false;
}
}
