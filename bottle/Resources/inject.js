try {
/*var ABall = document.getElementsByTagName("a");
for (var i = 0; i < ABall.length; i++) {
	var c = ABall[i];
	//if (c.class.search('ad') != -1) {
		c.style.display = "none";
	//}
}*/
var all = document.getElementsByTagName('*');
//alert("hallo");
var el;
for (var i = 0; i < all.length; i++) {
	var el = all[i];
	if (el.className.search('ad') != -1) {
		el.style.backgroundColor = "#FF0000";
		//alert("killed one ad again");
	}
	//if (el.className.search('ad') != -1) el.style.innerHTML = "<h1>HIER WAR EINE WERBUNG!!!</h1>";
}

} catch (err) {
alert(err);
}