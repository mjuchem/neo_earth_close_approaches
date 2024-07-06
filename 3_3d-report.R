library(tidyverse)
library(lubridate)
library(openxlsx)
library(stringr)
library(reshape2)
library(rgl)

LUNAR_DISTANCE <- 384402
ASTRONOMICAL_UNITS <- 149597900
AU_to_LD <- ASTRONOMICAL_UNITS / LUNAR_DISTANCE

d.raw <- read.xlsx("data/neo-earth-close-approaches_LATEST.xlsx")

d <- d.raw %>%
  mutate(
    cd = ymd_hm(cd),
    cd_date = as.Date(cd),
    dist = as.numeric(dist),
    dist_min = as.numeric(dist_min),
    dist_max = as.numeric(dist_max),
    dist_ld = dist * AU_to_LD,
    v_rel = as.numeric(v_rel),
    v_inf = as.numeric(v_inf),
    diameter = as.numeric(diameter),
    diameter_sigma = as.numeric(diameter_sigma),
    h = as.numeric(h),
    Is.Future = ifelse(cd >= today(), TRUE, FALSE),
    month = month(cd),
    year = year(cd)
    )

open3d()

d.past <- d %>%
  filter(
    !Is.Future
    )

INCOMPLETE_YM <- max(d.past$cd)

d_sum <- d.past %>%
  filter(
    dist_ld <= 100,
    !(month(cd) == month(INCOMPLETE_YM) & year(cd) == year(INCOMPLETE_YM))
    ) %>%
  group_by(year, month) %>%
  summarize(
    .groups = "keep",
    n = n()
    ) %>%
  ungroup()

m <- lm(
  formula = n ~
    poly(year, 2)
  # + poly(month, 4)
  + poly(year * month, 4)
  # + poly(year / month, 2)
  ,
  data = d_sum
  )
summary(m)

d_sum$n.pred <- predict(m, d_sum)

par3d(windowRect = c(20, 30, 1000, 1000))

bg3d(color = "white")

clear3d()

decorate3d(xlab = "Year", ylab = "Qtd.", zlab = "Month", box = TRUE, axes = TRUE, top = TRUE, aspect = FALSE)

spheres3d(x = d_sum$year, y = d_sum$n, z = d_sum$month, color = "yellow", radius = 2)

segments3d(
  x = t(cbind(d_sum$year, d_sum$year)),
  y = t(cbind(d_sum$n, d_sum$n.pred)),
  z = t(cbind(d_sum$month, d_sum$month)),
  color = "red",
  alpha = .5
  )

aspect3d(x = 1, y = 1, z = 1)

view3d(theta = 60, phi = 10, zoom = 1)

x <- d_sum %>% select(year) %>% unique()
z <- d_sum %>% select(month) %>% unique()
df5 <- merge(x, z) %>%
  arrange(year, month)
df5$n.pred <- predict(m, df5)

df6 <- df5 %>%
  mutate(m = paste0("v", month)) %>%
  dcast(year ~ month, value.var = "n.pred")

rownames(df6) <- df6$year

df6 <- df6 %>% select(-year)

y <- as.matrix(df6)

surface3d(
  x = x$year,
  y = y,
  z = z$month,
  front = "lines",
  back = "lines"
  )

rgl.snapshot(filename = "output/neo-earth-close-approaches.png")

htmlwidgets::saveWidget(rglwidget(width = 1080, height = 1080), "output/neo-earth-close-approaches.html", title = "Neo Earth Close Approaches")

# movie3d(spin3d(axis = c(0, -1, 0)), duration = 4, fps = 10, movie = "output/neo-earth-close-approaches", type = "gif", dir = getwd())
