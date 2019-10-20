docker build -t lucdang/multi-client:latest -t lucdang/multi-client -t lucdang/multi-client:$SHA -f ./client/Dockerfile ./client
docker build -t lucdang/multi-server:latest -t lucdang/multi-server -t lucdang/multi-server:$SHA -f ./server/Dockerfile ./server
docker build -t lucdang/multi-worker:latest -t lucdang/multi-worker -t lucdang/multi-worker:$SHA -f ./worker/Dockerfile ./worker

docker push lucdang/multi-client:latest
docker push lucdang/multi-server:latest
docker push lucdang/multi-worker:latest

docker push lucdang/multi-client:$SHA
docker push lucdang/multi-server:$SHA
docker push lucdang/multi-worker:$SHA

kubectl apply -f k8s
kubectl set image deployments/server-deployment server=lucdang/multi-server:$SHA
kubectl set image deployments/client-deployment client=lucdang/multi-client:$SHA
kubectl set image deployments/worker-deployment worker=lucdang/multi-worker:$SHA
