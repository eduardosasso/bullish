$(document).ready(function() {
  $("#chimp-form").validate({
    submitHandler: function(form) {
      $("#response").css("visibility", "hidden");

      $("#subscribe-button")
        .attr("value", "Submiting...")
        .prop("disabled", true);

      $.post(form.action, JSON.stringify({ email: $("#chimp-email").val() }))
        .done(function() {
          $("#subscribe-button").attr("value", "Done");

          $("#chimp-email").replaceWith(
            "<div id='success'>Thank you! 🎉</div>"
          );
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
