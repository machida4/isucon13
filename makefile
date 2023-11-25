.DEFAULT_GOAL := help

restart: ## Restart all
	@git pull
	@make -s nginx-restart
	@make -s db-restart
	@make -s app-restart

restart-1: ## Restart for Server 1
	@make -s restart

restart-2: ## Restart for Server 2
	@make -s restart

restart-3: ## Restart for Server 3
	@make -s restart

app-restart: ## Restart Server
	@sudo systemctl daemon-reload
	@sudo systemctl restart isupipe-go.service
	@echo 'Restart App Server'

app-log: ## Tail server log
	@sudo journalctl -f -u isupipe-go.service

nginx-restart: ## Restart nginx
	@sudo cp /dev/null /var/log/nginx/access.log
	@sudo cp go/nginx.conf /etc/nginx/
	@echo 'Validate nginx.conf'
	@sudo nginx -t
	@sudo systemctl restart nginx
	@echo 'Restart nginx'

nginx-log: ## Tail nginx access.log
	@sudo tail -f /var/log/nginx/access.log

nginx-error-log: ## Tail nginx error.log
	@sudo tail -f /var/log/nginx/error.log

nginx-alp: ## Run alp
	@sudo alp ltsv --file /var/log/nginx/access.log --sort sum --reverse --matching-groups '/api/user/[a-zA-Z0-9]+/theme, /api/user/[a-zA-Z0-9]+/icon, /api/user/[a-zA-Z0-9]+/statistics, /api/livestream/[0-9]+/statistics, /api/livestream/[0-9]+/icon, /api/livestream/[0-9]+/reaction, /api/livestream/[0-9]+/ngwords, /api/livestream/[0-9]+/report, /api/livestream/[0-9]+/moderate, /api/livestream/[0-9]+/livecomment, /api/livestream/[0-9]+/livecomment/[0-9]+/report, /api/livestream/[0-9]+/enter, /api/livestream/[0-9]+/exit'> alp.txt
	@dispost -f alp.txt

nginx-alp: ## Run alp with url sort
	@sudo alp ltsv --file /var/log/nginx/access.log --sort uri --reverse --matching-groups '/api/user/[a-zA-Z0-9]+/theme, /api/user/[a-zA-Z0-9]+/icon, /api/user/[a-zA-Z0-9]+/statistics, /api/livestream/[0-9]+/statistics, /api/livestream/[0-9]+/icon, /api/livestream/[0-9]+/reaction, /api/livestream/[0-9]+/ngwords, /api/livestream/[0-9]+/report, /api/livestream/[0-9]+/moderate, /api/livestream/[0-9]+/livecomment, /api/livestream/[0-9]+/livecomment/[0-9]+/report, /api/livestream/[0-9]+/enter, /api/livestream/[0-9]+/exit'> alp.txt
	@dispost -f alp.txt

db-restart: ## Restart mysql
	@sudo cp /dev/null /var/log/mysql/mysql-slow.log
	@sudo cp go/mysql.cnf /etc/mysql/
	@sudo systemctl restart mysql
	@echo 'Restart mysql'

db-digest: ## Analyze mysql-slow.log by pt-query-digest
	@sudo pt-query-digest /var/log/mysql/mysql-slow.log > digest.txt
	@dispost -f digest.txt

log: ## Tail journalctl
	@sudo journalctl -f

.PHONY: help
help:
	@grep -E '^[a-z0-9A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
