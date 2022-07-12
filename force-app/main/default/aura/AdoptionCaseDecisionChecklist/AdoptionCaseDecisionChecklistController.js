({
    onButtonPressed: function(cmp, event, helper) {
      var actionClicked = event.getSource().getLocalId();
      var navigate = cmp.get('v.navigateFlow');
      navigate("NEXT"); 
	}
})