g_base_plot <- ggplot() +
  labs(
    title = "Ethiopia IDPs",
    subtitle = "IOM DTM Asssessment Survey 50+ Sites",
    caption = caption
  ) +
  theme_void() +
  theme(
    text = element_text(family = ft, size = 48, lineheight = 0.3, colour = "#F90909"),
    plot.background = element_rect(fill = "#101319", colour = "#101319"),
    plot.title = element_text(
      size = 128,
      face = "bold",
      hjust = 0.5,
      margin = margin(b = 10)
    ),
    plot.subtitle = element_text(
      family = ft1,
      hjust = 0.5,
      margin = margin(b = 20)
    ),
    plot.caption = element_markdown(
      family = ft1,
      colour = colorspace::darken(txt, 0.5),
      hjust = 0.5,
      margin = margin(t = 20)
    ),
    plot.margin = margin(b = 20, t = 50, r = 50, l = 50),
    axis.text.x = element_text()
  )


g_region_name_bar <- disp_conflict |>
  filter(total_idps > 50) %>%
  ggplot() +
  geom_col(aes(region_name, total_idps, alpha = 1, fill = clr)) +
  scale_fill_identity() +
  geom_text(aes(4.7, 100, label = "Summary of round 32 and 33  site survey"), family = ft1, colour = "#F7DC6F", size = 16, nudge_x = 1, hjust = 0) +
  geom_text(aes(region_name, 5, label = region_name), family = ft, colour = bg, size = 14, hjust = 0, fontface = "bold", nudge_x = 0.2) +
  geom_text(aes(region_name, total_idps - 2, label = scales::comma(total_idps)), family = ft, colour = bg, size = 10, hjust = 1, fontface = "bold", nudge_x = -0.2) +
  coord_flip(clip = "off") +
  theme_void() +
  theme(
    legend.position = "none"
  )



g_final_plot <- g_base_plot +
  inset_element(g_region_name_bar, left = 0, right = 1, top = 1, bottom = 0.66) +
  # inset_element(g_us, left = 0.42, right = 1, top = 0.74, bottom = 0.33) +
  # inset_element(g_day, left = 0, right = 0.66, top = 0.4, bottom = 0) +
  # inset_element(quote1, left = 0.5, right = 1, top = 0.8, bottom = 0.72) +
  # inset_element(quote2, left = 0, right = 1, top = 0.52, bottom = 0.4) +
  # inset_element(quote3, left = 0.7, right = 1, top = 0.2, bottom = 0) +
  plot_annotation(
    theme = theme(
      plot.background = element_rect(fill = bg, colour = bg)
    )
  )

ggsave(plot = g_final_plot, filename = "Scripts//Ethiopia_idps.png", height = 16, width = 10)


