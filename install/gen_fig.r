library(ggplot2)
library(plyr)
library(dplyr)


library(scales)


# read data and put that into var

# may need to build from multiple sources, bind it
# make sure the fieldname/type is same
hall <- bind_rows(hnew, hold)


tmp <- new_sc_noht
# get 10-90 percentile
h_data <- tmp %>% group_by(runtype, input, bench, threads) %>% 
    filter(time < quantile(time, 0.90) & time > quantile(time, 0.10))

# get average data
ht <- h_data %>% # group_by(input, bench, threadss) %>% 
    summarise(ins_avg = mean(instructions), time_avg=mean(time)) %>% 
    filter(bench != "word_count_nosharing" & bench != "kmeans_nosharing" & bench != "pca")

# now we want to get ratio
## get native version first
ht_nat <- ht %>% filter(input == "native")
## lookup, merge, and divide
ht <- merge(ht, ht_nat, all.x=TRUE, by=c("runtype", "bench", "threads")) %>% 
    mutate(rat_nat = time_avg.x/time_avg.y) %>% select(-ends_with(".y"))



# plot per
ggplot(ht, aes(x = threads, y = time_avg, group = stat, colour = stat)) + geom_line(size = 1.2) + 
    facet_grid(bench~., scales="free") + scale_x_discrete(breaks = as.character(c(1,2,4,8,12,14)))


#apps

memcached <- memcached %>% rename(op = 'op-s', kb='kb-s')
tmp <- memcached
memcached_clean <- tmp %>% group_by(env, run) %>% filter(op < quantile(op, 0.90) & op > quantile(op, 0.10)) %>% 
    summarise(op_avg = mean(op), kb_avg = mean(kb))
memcached_clean$thr <- 136906.82
memcached_clean <- memcached_clean %>% mutate(thr_txt = percent(op_avg/thr))

redis_clean$run <- factor(redis_clean$run, levels = c("native", "ilr", "tx", "haft"))


#plot
ggplot(memcached_clean, aes(interaction(env,run,lex.order = TRUE), op_avg)) + 
    geom_bar(position='dodge', stat="identity") + 
    geom_text(aes(label=thr_txt), position = position_dodge(width = 0.8), vjust=-0.7) + 
    theme(axis.text.x = element_text(angle = 20, vjust=0.8)) + 
    labs(x="Running Mode", y="#operation/secs", title="Memcached throughput on HxSCONE")

#fig 2


#fig 3
x3 # from plot2
x3a$program <- factor(x3a$program, levels = c("word_count", "string_match", "matrix_multiply", "pca","linear_regression","histogram",  "kmeans"))

ggplot(x3a %>% filter(program != 'mean') %>% mutate(vals=mapvalues(mode, c(1,3,4,5), c("Native", "HxSCONE", "HxSCONE sim mode", "HxSCONE without configuration"))), aes(x = program)) + geom_line(size=1, aes(y = rat_haft, group=mode, linetype=vals, color=vals)) + geom_point(size=1, aes(y = rat_haft)) + scale_y_continuous(breaks = seq(1,7,by=1)) + theme_bw() + theme(legend.position = "bottom") + labs(x = "Benchmark program", y = "Normalized runtime\n(w.r.t native execution)", color="Execution mode") + scale_linetype(guide=FALSE)


#fig 5
x5$program <- factor(x5$program, levels = c("string_match", "matrix_multiply", "linear_regression", "kmeans", "pca", "histogram", "word_count", "mean"))
ggplot(x5 %>% filter(themode != "1_native") %>%
     mutate(val = factor(mapvalues(themode, c("3_native", "1_haft", "3_haft"), c("SCONE only", "HAFT only", "HxSCONE")))), aes(x = program, group=val))  + 
     geom_bar(size=1, aes(y = rat_haft, fill=val), stat='identity', position='dodge')  + 
     scale_fill_brewer(palette = "Set2") + theme(legend.position = "bottom") + labs(x = "Benchmark program", y = "Normalized runtime (w.r.t native execution)", fill="Execution type")

## note dataset
# nat_sc : (native : 1, scone-hw : 3) 4 threads only. hyper-threading on. scone-fork
# [1] "histogram"            "linear_regression"    "string_match"         "word_count"           

# Fig 2 : gcc vs musl
# 	open fig2 plot ready
#     reorder if necessary : 
#         > tmp2$program <- factor(tmp2$program, levels = c("matrix_multiply", "linear_regression", "string_match", "kmeans", "word_count", "histogram", "pca"))
#     plot to figure

# result-run-scone.log -> 3: scone-hw, 4:scone-sim		native haft only
# 	merge with (1) from logs_all to get native -> run_nat_excl

# sconelow -> 3: scone-low -> change this to 5