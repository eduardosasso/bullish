$(document).ready(function() {
  $("#chimp-form").validate({
    submitHandler: function(form) {
      $("#subscribe-button")
        .attr("value", "...")
        .prop("disabled", true);

      $.post(form.action, JSON.stringify({ email: $("#chimp-email").val() }))
        .done(function() {
          $("#response").css("visibility", "hidden");

          $("#chimp-email").replaceWith("<span>🎉🎉🎉</span>");
          $("#subscribe-button").attr("value", "Thank you!");
        })
        .fail(function() {
          $("#response").css("visibility", "visible");
          $("#response").text("Sorry but something went wrong!");
        });
    },
    rules: {
      email: {
        required: true,
        email: true
      }
    }
  });
});
