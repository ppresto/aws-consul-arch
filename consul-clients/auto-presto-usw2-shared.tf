#provider "azurerm" {
#  features {}
#}

module "consul_presto-usw2-shared" {
  source   = "../modules/helm_install"
  release_name  = "consul-usw2-shared"
  chart_name         = "consul"
  cluster_name         = "presto-usw2-shared"
  datacenter           = "presto-cluster-usw2"
  consul_partition     = "default"
  server_replicas      = 3
  consul_version       = "1.14.4-ent"
  consul_license       = file("../files/consul.lic")
  consul_helm_chart_template = "values-client-agentless-mesh.yaml"
  consul_helm_chart_version  = "1.0.2"
  consul_external_servers    = "presto-cluster-usw2.private.consul.328306de-41b8-43a7-9c38-ca8d89d06b07.aws.hashicorp.cloud" #HCP private endpoint address
  consul_ca_file             = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUVmRENDQW1TZ0F3SUJBZ0lVYVNZcEVqaGU3VnZYY1JoYlhtR1ZybFZHT2Zjd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0d6RVpNQmNHQTFVRUF4TVFTRU5RSUVSaGRHRndiR0Z1WlNCRFFUQWVGdzB5TXpBeU1UVXhOekkwTXpSYQpGdzB5TkRBeU1UVXhOekkxTURSYU1EWXhOREF5QmdOVkJBTVRLemcwTjJOaVl6QTFMV1ExWVdZdE5ESmlPUzFpCk5UWmlMVFUyTlRCa01UQXhZV0UwWkM1amIyNXpkV3d3Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXcKZ2dFS0FvSUJBUUN3WUxlV1dzRlY4a25HdStNMVpzY0QrUlp2VFhqdDNlZlkxblptZ05mWjVCMTNnQzRQMTZTMwpKMEU2ZWdVUTNtWit2Y2xlSGFGTXZYWllSanA5YW9PSmhja0MxNWtXMEp6ekcrRmdKNXVFbDZERSt3NXlWQ1hOCnVMb0tmajFzajhDckYweTFLQ3lQWVBTYVhsU3AzZTJ0MUdCbmt2dm55S0laRFhZWXd2cER3OWE1UU1aK0Q4Sm4KUnBFMzRMYStYekR0RS81KzdveWpjbXMwZHVxZTRXRlFGaTVHV1dOMlA3bGtXbUZ2STE5dE1ZSHowazN1a0EwYgovYktVOEdJU0cwNnZCc3ZBSkRSZjNQTHdaWUFRZmN5OXJhZXRJdlNpazhDRG8zOUlSVGtnWDEyR2lsNldYeFFyCmduUGdKNzVOYkdUdzBhQlFtenlydEZrdzB0Z0VUK3kvQWdNQkFBR2pnWnd3Z1prd0RnWURWUjBQQVFIL0JBUUQKQWdFR01BOEdBMVVkRXdFQi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZHZGRHMHlJYjQrQU5zcFo5b1JPWU5BTwpkMVJHTUI4R0ExVWRJd1FZTUJhQUZCU1JCNmF6ZU9aZFFXMlpOUzZRbW5wMFlsWkZNRFlHQTFVZEVRUXZNQzJDCkt6ZzBOMk5pWXpBMUxXUTFZV1l0TkRKaU9TMWlOVFppTFRVMk5UQmtNVEF4WVdFMFpDNWpiMjV6ZFd3d0RRWUoKS29aSWh2Y05BUUVMQlFBRGdnSUJBSnc4eU1iVTMrcnVWY0RlY3hCT2p5dGIxRjgxUnFKSFR3eHMxMFdhZlR3NgpZU2R0MThUY0hzTmJiMXJHM1ZXWlNraG5GcktuZitvWHZycXZuSy9hUlAwaWJ0N3BWQ1JFQ1c3NTlGRktTeEk4CmVBMUVOelJlUy9GeHYyckhWSDZMU0dzMFZPL0JLOXJidWJyay9YQVN4YVZWcGVDd3FkdUx6eUFiTEl1Nml2ankKVHRMMEtKd1ZhV3BTaVdtb3BzK0Z6UmIycTZGdndtczdRY1dQRXVnYTdXNmhHZHFFaENmZkF5MEs2MG9vTTJregpaanVMcmVYY0ZNRjdiQ1ZhZEJiSW0zb0x0MlV1R1dxTW5TU21FVzBlMUFSR2JENXp3ODV3NE4zblVOSUs5WDJtCmgwbFd3QW1aOGRuVzlyaDFsanlCYzhpQ1Uxak9WWUxiTWRDM1d5Q3NSZlJiQzJPNmkrb0F0YUJaSk0wZ3JSdUwKdzhWTXN2bjBubllSdXpySVB5YnhGZWM0MkZveUVsNTNmaUZ3c0FlYnVXaEE4SVVZQWZBazBWOGtBZ0NtaHdYTwpJRzJnZkhhdVorUS9EL1hmSUR5NEFnZWRQcWNVS1NSWU54RDlWVnJuN2NydVp3K0gwY21qb3FvVEdTMTdSbEw4CnJYSmNra3M3MFUyZE16eTBRK1FDcytzYXdodzU5b29GRlpLUVJXSlpETVZrNzRlazZ1dFdzS2Z3YXBzRUIvNkMKYUtkOU5JRWxCb2hscDBtZUdqTnEwQldFdlhSUE5wVXRWOE8vVzJiTVRSZGlUaE9GbmhDU3g2R1JhVVB5WjlKMQpRVTNxaTRWSmdoQ2JQVDN5WmtaVUxDamRmNTN6MjZDeU9nek9CR2Y3MlRiQ2hXaTZScFZYQ3RzeURtMnZMbXRnCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0KLS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZJRENDQXdpZ0F3SUJBZ0lVVkJtVy9kSkN3R3VKaXN4VldpTjk3Z0ZXdlZRd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0ZERVNNQkFHQTFVRUF4TUpTRU1nTVRBeElFTkJNQjRYRFRJd01EUXhOakU0TWpNMU5Wb1hEVEl6TURReApOakU0TWpReU5Wb3dHekVaTUJjR0ExVUVBeE1RU0VOUUlFUmhkR0Z3YkdGdVpTQkRRVENDQWlJd0RRWUpLb1pJCmh2Y05BUUVCQlFBRGdnSVBBRENDQWdvQ2dnSUJBS083bTVHQ0VNbkhWeGF4ZWhScUdielhOQlhFMWlxZEdlV0EKcUZUWjJCN0xuSmZoTnk3U2xic0VRZ1F3SGFTbkI5WWJNNUIwK3JUYmNYaFdkZ1BOUEkwQ0NrZWVrNmY5U3J3ZwpHSVR2VVVnbEF1YWVGa0RhOTY3SVhrYWZXVGdkOGdoTDN0eUQ5VGZIRWpuTS85UWJJcjZpL0dZOHMvZHdSN3FFCjVvWXpuRjQ4akQrNWQybXQranF1bE5ncjFDMkpqbjR5Uy90ZXdVVFdWZ1FmdEtLVnJ1cWMzRjJ1NVhnSDVrMXAKZFp3OEdoY1VsT0hTRnlwdUE3ZXlUaGZRRlRBRUlUUzM5VlltSnpsWHdtaGVPOUpiT2VRSFlMazYxMmhaTXFkYgpPbkg5K1crYTNLLzR5dHFGYTdqZmJzVVlsWkJKMlFKNHpvQjVlbm9BaVJyL0pxTHB5cDRUYmpQT2RSUWRjOExoCjlqZkVLU29WTjVaVWlTQ3E0cnFtM2ZQaXVZRTRJWEEwNjZocDBvZ0NwdjBJQjRSakptT2EzZWwyUy9WVDROd2wKazRkYlhyMzhLcCtmV0JSVE1qd2l1M1l3b1FaU284WXNJWkpLWlFDR1JpQStRMWJpTE8xcHVsbUFWR1lOWDdwMApIbWtkT2hnTU1ycWk0cEdQdGdPQmZEWk04NVhpZkRnQmhrL1JkRzBRc3k3cFNVZ25EYjVCQ3l3aEZOVy9ValNBCkRid0Jvc2dnWWRFUkZSTURCT0pmUUdaemJGcmZ1RExsQ1FvZTZVWm9sL3ZSMDlqTW1jcW5lcjF6MERQcTg4Y20KemZoUWo0M0gvUFpnSDBDUGo4aTVYSVpaUzlzWUhmOTlieHpaODVTejM3bUJRMGZMTDBiVDdrODdLekRrdUZleQpZTEtUZUI5M0FnTUJBQUdqWXpCaE1BNEdBMVVkRHdFQi93UUVBd0lCQmpBUEJnTlZIUk1CQWY4RUJUQURBUUgvCk1CMEdBMVVkRGdRV0JCUVVrUWVtczNqbVhVRnRtVFV1a0pwNmRHSldSVEFmQmdOVkhTTUVHREFXZ0JRZnFmSW8KeHVmUnRtL1QzM3ZQbGZBNVhmM04zREFOQmdrcWhraUc5dzBCQVFzRkFBT0NBZ0VBdE8zdStydjBSYTBCenB4QwpQQVlaWXYrSHd6ZldPMmhiZVB3WFlieGJIWGxWelV0NnMveTcxekRzWnNvN3lEeXBnSnpuUTc1WFFLYXFSVllVCjROQXVlbnh5aXA5NHdrYkpqZXpETmx3ZmVnbHhuVEk4MkQwWUkvMnRGZkNBbXFRbGg3N3RyZ1Rkb2pTYTR4UXUKcjBXc3lxejNGZENOdG1SZlRJRGJ4bkdjUFd1bk5odkxWZTVGZWplUUMrL2Nramh0QnVzQ280VWhqbGxxd1NTZgpWdzl3ck5kRzArS0xSUW1JN0t6Zm9pa3ZRV2dndW9CNTRYQXRYN3F2a3ZHTGUzcis4SDRKUC8zWVZDZWRRSjNjCnpEdnZKWVhpS2VZN0tyNzFSNUwrVHlla09jM204NjBRM3orRFVKSmFzUGJpb3FjU0xXcVpYb0hjMlVIM0xSTUIKWndFeUZFdS93UzF0UU1CdC9IejUwZk52UDc5UWUySHR1SjlSbm0rQ3NIL2x4RUg2eCtjdENIWjE2cmlsclhJZgpZdG5qRkJERDFNSlRKY0lGMkNkSGFxT0gvTkIzdC9xaWxYVmg5VkFUZHlTV1djb3ZTZGdhYVpXU2lOaVJEUGZiCkNySFNrajMvcW15SWVJa014M1BISm82cVNCQUNjclp2N3lYV1I5Tzg2Y014cThVWEE3ZkxkbjdzSDljTFNrRWcKV1ltM1lhb3RlTE9LRk5LbUpPZVlNcCtURXVqL2QzYWNFWFprZ05FUjlVL1VuTFZ4WTZVaDBRdVhVUWgwaWlEUApOSkM1cEZMYkt6R3dwRmNKdHdtWDRZMU1pOEUwZXlwZS83a0lvWksxUXBoMEVjREllSHhOS2F4OHRUdEpZSUlHCmx1SG1GekRmekVIVzJ2b09QTzVXRzBGOXQ3TT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQotLS0tLUJFR0lOIENFUlRJRklDQVRFLS0tLS0KTUlJRklUQ0NBd21nQXdJQkFnSVVSVndtcTBYZkViYTBjUnM5UnhpbGNDN3VCK293RFFZSktvWklodmNOQVFFTApCUUF3SERFYU1CZ0dBMVVFQXhNUlNHRnphR2xEYjNKd0lGSnZiM1FnUTBFd0hoY05NakF3TkRFMk1UZ3hPVEV3CldoY05NekF3TkRFMk1UZ3hPVFF3V2pBVU1SSXdFQVlEVlFRREV3bElReUF4TURFZ1EwRXdnZ0lpTUEwR0NTcUcKU0liM0RRRUJBUVVBQTRJQ0R3QXdnZ0lLQW9JQ0FRRGZ5NmlHVVJZenlFdUFscGROSWcyWjVQQ1ZhTklLalh6dAppTlN4TUZtYkVWS0VxTGlicFVITTZVWTMxU2plK1BQNzRXUTdTN2tIY3dKYmdXTnVtR0l6aG9IWE9BUlM0SWpCClgzeGwweVJ2bkxFOWNZMldSYzRVR0MvU0ZNRVJJS1Z3c1puRVVWQTB4bkJUenV6U0xiWEpTczZ4d0lCZ2FlWlMKY1VUdGtiaHl3bU5sNWNwdWJneFBOdkpkQWRNWk9PNkczc1M1YmtFc3dWMWVwWVQwZ2s4anhmZ0Y4anA4QXlCMQpIbWpxTWlzcnhIVGZNd0FBbUx4ZndrMUM1YWFGVmt5M2FWZ0xTanVNaG1LSkhSZ2xURENRa2FzRmhnUkk3OVJGCjlqdDl0SzBFRDExVk02RUIzUlY0aGpVbHUzdVJ6SlZiRDY4RXdrcUJJcnd4VzY3bFd6cmlSam0wTlRUL2R6UksKdzJ3UkJ4TDM0MnYyUXN5WGg3aFdRQjhOclFJMkxXVnVPRzhEY0xiTWl2UEsxQ3VzellrZEc2MGFZTzdrK1NtdApYUlVxK0tKeXFwZ1Q1Zk95YVFrUTY0aVRxRDkxR1pabGVYTjFiZVE1KzcxS3liRHRuT1Nham9yWW1URDBreWpQCnZlYThWN0w5UU9VbGxFV2o0T1g2Z0c1U2g0SllXSWJIamFzQU1JSFhXOW5sTXVQbnV4cE1LSlB1eldkRjNMZE0KNWpuUEVIaGJWaSsxRmxIR2J3MVUrQkN0NzVXT09XSkVZUzFpcVpsZnd0K2lnMnF0elcxMElGYWJYWUFjeXVlTQpoMU8wNGpuUndxNEhLMFEvVnZGVjd1eGdsOEw0S0NTcmh0TTQzclZkbVRnMFpOeFI3VmZDaEFiTnMvbUNWeGo2CmhXZU1pNHZSOXdJREFRQUJvMk13WVRBT0JnTlZIUThCQWY4RUJBTUNBUVl3RHdZRFZSMFRBUUgvQkFVd0F3RUIKL3pBZEJnTlZIUTRFRmdRVUg2bnlLTWJuMGJadjA5OTd6NVh3T1YzOXpkd3dId1lEVlIwakJCZ3dGb0FVVHRVcApqYzFDV1Bvd1pJdjNiSmpENVlDTVNhSXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnSUJBSHFraXNCbW02U0taVmlOCkZUMWw0dWxvRzFrQ0hlZ2lCdkYray9nYURIaVZ2N0ZUSGFJaElTY0EvMUhUeVdscFg4ZTlWclRUbUhiZ2lwMlcKSUdSdWtWQ0JrdDd6WUFqQWU0MmJzeWVSaWcxYUNQQytGb1BOSFM0b0ZxYUFsNlM4ZXh1eTd1NUdXTCtMek5xbwo2a2NKK3NHQ3ZUUEJyeGZqWEpxZmRwOTFWTWZ2OW1WZkZETmFMQXJXVGx6aHJVQVNvZGhmeXN1OHVHelo1bWJQClkweEJUVFlxM1VsTSszT01mTnY5WGpuOWV2RkFBNHJmTWdpSDdNc1hpM2N1Rm9mNGtzL3pCd2VwNWd3b3F6MFcKbEE2Zm9ZQlluTGVlOTljUmpXQ0hmYXdNby8xYnIwSlZzSWlhWmsvdkdENDBabk1Kcmg5a0hDcnc1TzJpV1hFSAphajFEN0MzTjBQQ3F1TUo5TnZVK3NSWE45b3UzbVV2UE9EUS9hQ0lNQTRxMnlMUHh5MGFvNW9sbmRncWlIaHRFCm1OVW83dzdnWHBxNlkrRXR2YkFBNHhUWDBJMWtibTl2d3pOVFo3d0xmS01IdEhxN0ZmcjdncVdYVTJjWG1sNlYKZnIxTXN2OGhVekR2SDFCZU55TUZ5ekZiSkpkcGZzS1JQaDcySWx4Y1F4c3I2a0loWTFLN3RGOGxRNWc5UlBueQowOSt2MTRPT3BDRzgzR1h1VUVJbFVCUWdxQmRUUDlRVnU3ck03MGlmMFlpZDlKeHdpbGhmblR0NVBuUEdCaHhyCmFzT24rM09wbzhINnZKV0xZeVllbEhmTFVBSGhpMk40R0FQL0w2QisvMldRcHltUTh3NjdLWW95bXJjK0s5WksKMmt2TW9KYm0yYWlhNllMbmdaSytuL1NLUm45bwotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCi0tLS0tQkVHSU4gQ0VSVElGSUNBVEUtLS0tLQpNSUlGS1RDQ0F4R2dBd0lCQWdJVVZLUitqOXNPeFhUQmFYOE9XRlFEM3NXNkZNb3dEUVlKS29aSWh2Y05BUUVMCkJRQXdIREVhTUJnR0ExVUVBeE1SU0dGemFHbERiM0p3SUZKdmIzUWdRMEV3SGhjTk1qQXdOREUyTVRneE9ERTAKV2hjTk5EQXdOREUyTVRneE9EUXhXakFjTVJvd0dBWURWUVFERXhGSVlYTm9hVU52Y25BZ1VtOXZkQ0JEUVRDQwpBaUl3RFFZSktvWklodmNOQVFFQkJRQURnZ0lQQURDQ0Fnb0NnZ0lCQU1iQnRTNTNDeXc2TnNDYmZnVy9WL1YxClRyUlFPTUZhUkF6WXlHcU8zT21OYlJRZmhVTm4vSk56bzdGWmFLeitpOVVNOUpzUGtvd1ZwbWRoSlRhVlVqS0kKamxGUWdmZmFrTXRmT1FlQk0wOFBRZldIUnRnVU0xMUEzS0Jlc1hvOFdOYWhhNTlDeW4rU3g4OFZVbDNLbmRkMQpyT3BKRHNRSG9aN3Y2MVM5Qm9EeFhwcmlsa1VKRENRYVBYZjIyUFZIeXNEbWFELzUvcTJwUVYra1ZzV1RZSkpxCi9YLzRaTjhXZWt2dlhLTUNEcUV6ejVYUU9iLzhrTldPVEc2L0hYZlFsWEZKZm1UdTBqVGs1N1RrakYrYU8zOTcKRnp2SG9reFJoc3ExK0FibHVqajU5NHM4N29rMi9wc0RnN1IremhQdWp0c2FCMGdtQUZNeTNKYUJpaHAycmJXUgpRYUxHM0hDTlFXbGErdVlUaFlneDhndHNNaGJBZlVXdHJsYnYzZ1g3b3VWbUZDYmpKa0hxNytFQkMzeWYySGU2CkovUWtHMzl6a0RmbVBjTjBudUZ5M0sraTFxaXZZNnBpZHMvZWF6dFRUVGE1WVRZc3MwYTlmMjRpZWREUWJyZE0KQ09ENDRwNjlVR3F6ZUxCRUFjeUl0aGtMVmhYOTlVQTBrZ01mNVJMekNYd2VPK1h5OVlhR1AyK2hJWHJEMXBDRgpjK2hRVTFpZkhLbXdjV3Nyb3hxQkh0Y1hiSHh4bVVsUTlQSUZzVUxCZjMxTUYxQU5BUnBWR3hNeVAwZmhEYXUzCnhOMC9YejBEaVhKdHhwaG5YUGt2UGt4U25TVnNRVTZHbVpjQU55c3pXTGhMYUNnWmw1eXNXSlpYSVdjbGJ5aXkKUllUMVYvNkJqYVg1c0FxSURDRGRBZ01CQUFHall6QmhNQTRHQTFVZER3RUIvd1FFQXdJQkJqQVBCZ05WSFJNQgpBZjhFQlRBREFRSC9NQjBHQTFVZERnUVdCQlJPMVNtTnpVSlkrakJraS9kc21NUGxnSXhKb2pBZkJnTlZIU01FCkdEQVdnQlJPMVNtTnpVSlkrakJraS9kc21NUGxnSXhKb2pBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQWdFQVNGSEMKckdYVC82WjF0QnE0UGtnSzkxeERXVCtOejZ5TXZCZTNYZHdLZ0V3VmJqSnlJVUlXM2tVZkt6dEJlMVhyOVROUQpuQURadEF6cHNrdXdwdnhRRmhFcXFVYU4xdmppbno1NWRSOHNNbTgxdzhPczFTR3RTek0walV5cCs2MTlkNldOCm9LMU1OSWk0NjNQR1FRTzVXUVZvNEdQTC9aN01hcTA4TnRhRlZqc2NMM1ljU2s5dnN3UmsvUnV5bjNUMUFVZzIKd05NeUZRdmxFWXB6VFpTWk9XenJ5WWYwZURIVUQ1Mk1VN29mNGZsQmVOVlJBNTAzZjc0R0w2YU02Q3lneldOZgphcEhmV2ZHdkpoZDVnNTFETm8xeTBkN1Vvbk56bm9vcFZOcTdnWmNrQU8ySFFONG9nS0VzM3pFaVo2TzRnWXVwClA0VDg4bGJia2xkVklZdTFIRnJ2TXJUcmJZQnhkY2N0VXNVU1J0RGdaeU51ZVNKZ1FFcUkvMG1BM1c4dmZRMk0KRzlCanJreUlGaTlVSFMwQTlKUjlXZmpnWEQvTkdKZ215R0JJMndwdFFjTTNsaWQyV1RLQU01cjA0SWc5RmtXYgpqLzRtS0hEUEU3anJnNVp0Z0J0b25ZNEc3T2VYZkYrSnhRTkoyOUZiaVM0M0RvM0JaajJ4S29iN0VHQnAzd2MzClZkTkhVamFabGlkUUJPZGlLanNUYktRVnZWcmpaUVNYNmtFTHlhT2RvcGc1NE85K3NCcXpTTzdPL1Z2aHhMMTcKeENpOW5keFcvTmZFbm5CbnJJZ21zVEdIQVdueXFzUWh4VlAyYXFIbTdhanZZK1AwSWlMT3pTM1hJYW1lSlZOOQpYdnZIRUN2QXNhNTlQeGNyRlhhd1lMam5lWlN1bFhWUk0xR3hwZFU9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0="
  consul_config_file             = "eyJhY2wiOnsiZW5hYmxlZCI6dHJ1ZSwiZG93bl9wb2xpY3kiOiJhc3luYy1jYWNoZSIsImRlZmF1bHRfcG9saWN5IjoiZGVueSJ9LCJkYXRhY2VudGVyIjoicHJlc3RvLWNsdXN0ZXItdXN3MiIsImVuY3J5cHQiOiJJQ0hJQVMrNGRSa0xUQUkrdjZmZGpRPT0iLCJlbmNyeXB0X3ZlcmlmeV9pbmNvbWluZyI6dHJ1ZSwiZW5jcnlwdF92ZXJpZnlfb3V0Z29pbmciOnRydWUsInNlcnZlciI6ZmFsc2UsImxvZ19sZXZlbCI6IklORk8iLCJ1aSI6dHJ1ZSwicmV0cnlfam9pbiI6WyJwcmVzdG8tY2x1c3Rlci11c3cyLnByaXZhdGUuY29uc3VsLjMyODMwNmRlLTQxYjgtNDNhNy05YzM4LWNhOGQ4OWQwNmIwNy5hd3MuaGFzaGljb3JwLmNsb3VkIl0sImF1dG9fZW5jcnlwdCI6eyJ0bHMiOnRydWV9LCJ0bHMiOnsiZGVmYXVsdHMiOnsiY2FfZmlsZSI6Ii4vY2EucGVtIiwidmVyaWZ5X291dGdvaW5nIjp0cnVlfX19"
  consul_root_token_secret_id = "860f728b-3182-7506-7afd-c9b635d9fe7e"
  }

