

#### Render different Tab Server Files ####
shinyServer(function(input, output, session) {
  waiter_hide()
  render_cancer_tab(input, output, session)
  render_heatwave_tab(input, output, session) # make sure to source the other server file above
})