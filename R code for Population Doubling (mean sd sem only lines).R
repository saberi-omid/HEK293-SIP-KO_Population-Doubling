# پکیج‌ها
install.packages(c("tidyverse", "rstatix", "car", "emmeans"), dependencies = TRUE)

library(tidyverse)
library(rstatix)
library(car)
library(emmeans)

# Make data
dat <- tribble(
  ~Control, ~Clone5, ~Clone9, ~Clone44,
  0.6462, 0.657, 0.976912, 1.02203,
  0.922728, 0.63, 1.063275, 0.904749,
  1.014798, 0.936, 0.749309, 0.819811,
  0.881285, 0.528, 1.103946, 0.819811,
  0.828476, 0.144, 0.694783, 0.953445,
  0.861654, 0.276, 0.785381, 0.909307,
  1.245285, 0.152, 0.841187, 0.87157,
  1.000000, 0.431, 0.851530, 0.968964,
  0.952660, 0.175, 0.927120, 0.992427,
  0.890431, 0.482, 0.887402, 1.028292,
  0.960881, 0.233, 0.900147, 0.989671,
  1.036175, 0.197, 0.867761, 0.960555,
  0.887402, 0.441, 0.936907, 1.116330,
  1.153144, 0.233, 1.073959, 1.000000,
  0.903677, 0.563, 1.141961, 1.010112,
  0.979115, 0.195, 0.797439, 0.968672,
  1.229716, 0.212, 0.816134, 1.009523,
  1.029154, 0.330, 0.709211, NA,
  1.165279, 0.216, 0.976167, NA,
  1.045427, 0.078, 0.935785, NA,
  0.820773, NA, 0.903677, NA,
  1.174521, NA, 0.812635, NA,
  0.935922, NA, 1.107309, NA,
  1.174521, NA, NA, NA
)

long <- dat |>
  pivot_longer(everything(), names_to = "group", values_to = "value") |>
  drop_na() |>
  mutate(group = factor(group, levels = c("Control","Clone5","Clone9","Clone44")))

# sample numbers in each group
long %>% count(group)

# descriptive summary
long %>% group_by(group) %>% get_summary_stats(value, type = "common")

# check assumptions
# check normality in each group (Shapiro-Wilk) 
norm_tbl <- long %>% group_by(group) %>% shapiro_test(value)
norm_tbl

# check variance equation (Levene)
levene_test(value ~ group, data = long)

# همچنین می‌توان Bartlett را (اگر نرمالیتی OK بود) تست کرد:
bartlett.test(value ~ group, data = long)

# ---------- 3) انتخاب و اجرای آزمون ----------
# حالت A: نرمال + واریانس‌ها برابر + n‌ها تقریبا متوازن -> One-way ANOVA
# (اگر بالا تایید شد)
fit_aov <- aov(value ~ group, data = long)
summary(fit_aov)

# Post-hoc (همه با همه: Tukey)
TukeyHSD(fit_aov)

# Post-hoc (فقط مقایسه با Control: Dunnett با emmeans)
emm <- emmeans(fit_aov, ~ group)
contrast(emm, "trt.vs.ctrl", ref = "Control", adjust = "dunnett")

# حالت B: نرمال اما واریانس‌ها برابر نیست / n نامتوازن -> Welch’s ANOVA
oneway.test(value ~ group, data = long, var.equal = FALSE)

# Post-hoc مناسب Welch: Games–Howell
long %>% games_howell_test(value ~ group)

# حالت C: نرمالیتی رد شد -> Kruskal–Wallis + Dunn
kruskal.test(value ~ group, data = long)
long %>% dunn_test(value ~ group, p.adjust.method = "holm")

# ---------- 4) شکل پیشنهادی ----------
# Boxplot با همه نقاط
ggplot(long, aes(group, value)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.15, alpha = 0.7) +
  labs(x = NULL, y = "Measurement") +
  theme_minimal(base_size = 13)

# Convert to long format
long <- dat %>%
  pivot_longer(cols = everything(), names_to = "Group", values_to = "PDPD") %>%
  drop_na()

long <- long %>%
  mutate(Group = fct_recode(Group,
                            "Control"  = "Control",
                            "Clone 5"  = "Clone5",
                            "Clone 9"  = "Clone9",
                            "Clone 44" = "Clone44"))


ggplot(long, aes(x = Group, y = PDPD, color = Group)) +
  geom_jitter(width = 0.2, size = 2, alpha = 0.7) +
  
  # Mean ± SD (آبی)
  stat_summary(fun.data = mean_sdl, fun.args = list(mult = 1),
               geom = "errorbar", width = 0.3, color = "blue") +
  
  # Mean ± SEM (مشکی)
  stat_summary(fun.data = mean_se, geom = "errorbar",
               width = 0.15, color = "black") +
  
  # Mean point
  stat_summary(fun = mean, geom = "point", shape = 18, size = 4, color = "red") +
  
  theme_minimal(base_size = 14) +
  labs(x = "Cell Line", y = "PD/Day") +
  theme(legend.position = "none")
